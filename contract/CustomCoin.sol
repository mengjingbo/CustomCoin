pragma solidity ^0.4.16;

contract Token {

    /// total amount of tokens
    /// 总发行量
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @param _owner 通过_owner参数从地址中获余额
    /// @return The balance
    /// @return 返回余额
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @notice 从msg.sender中发送_value到指定地址
    /// @param _to The address of the recipient
    /// @param _to 收币人地址
    /// @param _value The amount of token to be transferred
    /// @param _value 要转让的总量
    /// @return Whether the transfer was successful or not
    /// @return 成功返回true
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @notice 在_from同意的条件下，发送_value到指定地址
    /// @param _from The address of the sender
    /// @param _from 发币人地址
    /// @param _to The address of the recipient
    /// @param _to 收币人地址
    /// @param _value The amount of token to be transferred
    /// @param _value 要发送的量
    /// @return Whether the transfer was successful or not
    /// @return 成功返回true
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _spender 可以转账代币的账户地址
    /// @param _value The amount of tokens to be approved for transfer
    /// @param _value 被批准转账的代币数量
    /// @return 成功返回true
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _owner 拥有代币的账户地址
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _spender 可以转账的账户地址
    /// @return Amount of remaining tokens allowed to spent
    /// @return 返回剩余的代币数量
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    /// 转账
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        require(balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        require(balances[_to] + _value > balances[_to]);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract CustomCoin is StandardToken {

    function () public {
        //if ether is sent to this address, send it back.
        revert();
    }

    /// 代币名字
    string public name = "Custom Coin";   //fancy name: eg Simon Bucks
    /// 代币精度
    uint8 public decimals = 18;        //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    uint256 private supplyDecimals = 1 * 10 ** uint256(decimals);
    /// 代币标识
    string public symbol = "CC";      //An identifier: eg SBX
    /// 代币版本
    string public version = 'v0.1';    //VNC 0.1 standard. Just an arbitrary versioning scheme.
    /// 创始人地址
    address public founder;            // The address of the founder

    /// @param supply first supply
    /// @param supply 首次发行量
    function CustomCoin(uint256 supply) public {
        founder = msg.sender;
        totalSupply = supply * supplyDecimals;
        balances[founder] = totalSupply;
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }

    /* Approves and then calls the contract code*/
    function approveAndCallcode(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        //Call the contract code
        if(!_spender.call(_extraData)) { revert(); }
        return true;
    }

    /// add total supply amount
    /// 增加总供应量接口
    function addTotalSupplyAmount(uint256 supply) payable public {
      totalSupply += supply * supplyDecimals;
      balances[founder] += supply * supplyDecimals;
    }
}
