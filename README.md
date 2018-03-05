## 创建遵守REC20协议的数字货币并实现转账及合约验证

### MetaMask钱包

MetaMask钱包是一个浏览器插件钱包，MetaMask比以太坊提供的客户端钱包要好用很多，更加的方便和快捷，使用时不需要在去同步庞大的区块数据。

##### [点击查看MateMask钱包安装教程](http://8btc.com/thread-76137-1-5.html)

##### [点击进入MetaMask官网](https://metamask.io/)

准备就绪后如果账户中没有可用的测试币可按照一下步骤去获取。

![MetaMask钱包](https://github.com/mengjingbo/CustomCoin/blob/master/image/29.png?raw=true)

点击 **ROPSTEN TEST FAUCET** 按钮跳转到获取页面，向上面的账户 **0x81b7...** 请求测试币，点击 **request 1 ether from faucet** 按钮发起请求。

![MetaMask钱包](https://github.com/mengjingbo/CustomCoin/blob/master/image/33.png?raw=true)

得到测试币后进入到MetaMask钱包的账户页面，如下：

![MetaMask钱包](https://github.com/mengjingbo/CustomCoin/blob/master/image/1.png?raw=true)

说明：Rpsten Test Net 为测试网络环境，账户 Account1 的地址为：0x7A9B... ，3.000ETH 为账户余额。

### 编写智能合约

推荐使用 **Atom** 工具进行编写，也可以在 **Remix** 编辑器中进行编写 

##### [点击进入Remix编辑器](https://remix.ethereum.org/#optimize=false&version=soljson-v0.4.19+commit.c4cbbb05.js)

代币合约如下：

```solidity
pragma solidity ^0.4.16;

contract Token {

    /// 总发行量
    uint256 public totalSupply;

    /// @param _owner 通过_owner参数从地址中获余额
    /// @return 返回余额
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice 从msg.sender中发送_value到指定地址
    /// @param _to 收币人地址
    /// @param _value 要转让的总量
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice 在_from同意的条件下，发送_value到指定地址
    /// @param _from 发币人地址
    /// @param _to 收币人地址
    /// @param _value 要发送的量
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @param _spender 可以转账代币的账户地址
    /// @param _value 被批准转账的代币数量
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner 拥有代币的账户地址
    /// @param _spender 可以转账的账户地址
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
        /// 如果ETH被发送到该地址，则返回给他
        revert();
    }

    /// 代币名字
    string public name = "Custom Coin";   
    /// 代币精度
    uint8 public decimals = 18;        
    uint256 private supplyDecimals = 1 * 10 ** uint256(decimals);
    /// 代币标识
    string public symbol = "CC";      
    /// 代币版本
    string public version = 'v0.1';    
    /// 创始人地址
    address public founder;           
    
    /// @param supply 首次发行量
    function CustomCoin(uint256 supply) public {
        founder = msg.sender;
        totalSupply = supply * supplyDecimals;
        balances[founder] = totalSupply;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }

    function approveAndCallcode(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(_extraData)) { revert(); }
        return true;
    }

    /// 增加总发行量接口
    function addTotalSupplyAmount(uint256 supply) payable public {
      totalSupply += supply * supplyDecimals;
      balances[founder] += supply * supplyDecimals;
    }
}
```

将编写好的合约代码Copy到编辑器中同时刷新一下浏览器确保合约是最新，如图：

![编写好的合约代码Copy到编辑器中](https://github.com/mengjingbo/CustomCoin/blob/master/image/2.png?raw=true)

点击 **Run** 按钮,切换到 **Run** 视图，如下：

![Run试图](https://github.com/mengjingbo/CustomCoin/blob/master/image/3.png?raw=true)

##### 描述：

- Environment：选择要编译的环境  
- Account：代币创建者的地址  
- Gas limit：矿工费限额  

### 开始创建代币并提交支付需要消耗的费用

点击 **Create** 开始创建代币合约，在 **At Address** 栏中，默认选择当前创建地址为

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/4.png?raw=true)

点击 **SUBMT** 进行提交。

### 查看区块记录

在MetaMask钱包中查看

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/5.png?raw=true)

在Etherscan上查看正在确认的区块记录

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/6.png?raw=true)

区块确认成功后如下：

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/7.png?raw=true)

在编辑器输入台查看确认成功后区块数据

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/8.png?raw=true)
![](https://github.com/mengjingbo/CustomCoin/blob/master/image/9.png?raw=true)

### 添加创建成功后的代币 

可以看到代币创建成功后由之前的3ETH减少到现在的2.996ETH，其中0.003301598ETH作为矿工费消耗掉了。

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/10.png?raw=true)

接下来添加代币，切换到 **TOKENS** 页，点击 **ADD TOKEN** , 将CC币的地址Copy到如图所示：

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/11.png?raw=true)

点击 **Add** 进行添加，添加成功后可看到当前账户有10000CC币

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/12.png?raw=true)

### 从编辑器视图查看区块状态 

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/13.png?raw=true)

### 使用MyEtherWallet

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/14.png?raw=true)

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/15.png?raw=true)

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/16.png?raw=true)

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/17.png?raw=true)

### 转账

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/18.png?raw=true)

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/19.png?raw=true)

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/20.png?raw=true)

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/21.png?raw=true)

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/22.png?raw=true)

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/23.png?raw=true)

### 转账查询

转账成功后在Account2中添加代币，即可看到1000CC币

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/24.png?raw=true)

此时Account1中剩余9000CC币

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/25.png?raw=true)

### 在Etherscan上代币查询 

##### [点击进入Etherscan网站]()

在Etherscan上输入代币符号进行搜索，如下：

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/26.png?raw=true)

进入代币详情页进行查看

![](https://github.com/mengjingbo/CustomCoin/blob/master/image/27.png?raw=true)

##### 描述：

- Total Supply：代币发行总量
- Value per Token：代币单价(需要向Etherscan发送邮件进行添加)
- Token Holders：代币持有人数量
- ERC20 Contract：代币地址
- Token Decimals：代币小数位数
- Official Links：官方链接(需要向Etherscan发送邮件进行修改)

### 代币合约验证

代币验证只是为了能让其他用户更加方便的阅读合约，代币验证时填入基本信息以及Copy代币合约，具体填写如下：

![Etherscan](https://github.com/mengjingbo/CustomCoin/blob/master/image/28.png?raw=true)

填完后点击开始验证，验证成功如下所示：

![Etherscan](https://github.com/mengjingbo/CustomCoin/blob/master/image/30.png?raw=true)

查看验证后的代币资源：代币合约代码/ABI/十六进制码

![Etherscan](https://github.com/mengjingbo/CustomCoin/blob/master/image/31.png?raw=true)

![Etherscan](https://github.com/mengjingbo/CustomCoin/blob/master/image/32.png?raw=true)

代币创建，转账和到验证到此结束。
