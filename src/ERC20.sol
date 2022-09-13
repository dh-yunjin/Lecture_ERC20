// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {

    // state
    mapping(address => uint256) private balances; // 주소를 넣으면 잔고가 나온다
    mapping(address => mapping(address => uint256)) private allowances; // 주소를 넣으면 그에 맞춘 매핑 - 잔고가 나온다
    uint private _totalSupply;

    // metadatas
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor () { // 선언된 변수에 직접 대입하는 것이 아닌 constructor를 사용함
        _name = "DREAM";
        _symbol = "DRM";
        _decimals = 18;
        _totalSupply = 100 ether;
        balances[msg.sender] = _totalSupply; // *
        // this는 이 '컨트랙트'를 의미함
        // 개인이 아니라 컨트랙트에 잔고가 있어봤자...어떤 의미가 있는지
    }

    // metadatas 밖에서도 확인할 수 있게 getter 필요
    // token이 한 번 발행되면 바뀌어서는 안됨 - view로 선언
    function name() public view returns (string memory){
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

    // Methods ----------------------------------------------------------------
    // states 밖에서 확인할 수 있게 getter 필요
    // token이 한 번 발행되면 바뀌어서는 안됨 - view로 선언
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }

    // 2명이서만 하는transfer 함수 구현
    function transfer(address _to, uint256 _value) external returns(bool success){
        require(balances[msg.sender] >= _value, "value exceeds balances");
        require(_to != address(0), "transfer to the zero address"); // 추가1
        // 공격 transaction 막기 위함
        // (놓침) _____가 ~...node 내에서도 solidity 내에서도, 0이 초기화된 값이니까 실수가 나도 실제로 전송이 안되게끔하려는 목적이 강함

        // require는 앞쪽에 몰아서 쓰는게 좋음 - transaction revert 빨리 일어나게
        // stroage 접근만으로도 gas 먹음
        // revert될 경우 (3가지 유형...) 이유없이 죽으면 gas limit만큼 consume
        // 완료될 경우 돌려줌 (설명 보충 필요)

        unchecked{ // 추가2 -- 어떤 말 했는데...
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
        // 누구한테, 얼만큼 전송할건지
        // external로 하든 public으로 하든 관계 없음
        // balances가 전송하는 것 (호출자의 balances를 value만큼 줄이고 보낼 사람 value만큼 증가)
        // value가 내가 갖고있는 것보다 많이 전송하면 안됨(같거나 적어야 함)
        // require 사용해서 value가 내 잔고보다 작은지 확인
        // Transfer event를 emit
        // zero address로 들어가버리면 token이 버려지기때문에 require 통해서 제한이 필요
        // => emit은 must하고 throw하는 건 should지만...
        // 실제로도 많이 일어남 - UI 통해서도 사용자가 하는 경우, 개발 실수, 버그, ...
        // 이를 막기 위해 zero address로 못들어가게 막아야 함
    }

    // 제 3자 거래
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success){
        require(balances[_from] >= _value, "value exceeds balances"); // 이거...무지성으로 복붙했는데 msg.sender가 아니라 _from이어야하지않나?
        require(_to != address(0), "transfer to the zero address");
        // 여기까지 require는 동일함

        uint256 currentAllowance = allowance(_from, msg.sender); // 현재 한도 불러오기
        require(currentAllowance >= _value, "insufficient allowance"); // 한도 가능성 보기
        unchecked {
            allowances[_from][msg.sender] -= _value; // 거래했으면 한도 줄여야함
        }
        
        require(balances[_from] >= _value, "value exceeds balances"); // 잔고 확인하기
        unchecked{
            balances[_from] -= _value; // 거래했으면 보내는 사람 잔고 줄이기
            balances[_to] += _value; // 거래했으면 받는 사람 잔고 늘리기
        }
        emit Transfer(msg.sender, _to, _value); // 거래 이벤트 emit하기

    }
    // 잔고를 인출할 address한테 얼마나 허용할거냐
    // c한테 a가 얼마나 인출을 허용할것인가를 currentAllowance에 넣어놓고 허용값보다 큰지 검사
    // 내가 인출한 값을 허용해놓은 값에서 뺌

    // transferFrom에 의해...제3자 송금 가능성
    // c가 마음대로 a의 돈을 b에게 모두 전송할 가능성을 방지하기 위해
    // a가 b에게 얼마나 허용할지를 정해놓음(approve과 allowance)
    
    // 사용예 drm_token.approve(bob, 10 ether); // 이만큼 설정한다는 뜻?
    // approve 다음 drm_token.allowance(address(this), bob)가 연달아서 사용됨

    function approve(address _spender, uint256 _value) public returns (bool success){
        // 거래 한도 설정하기(단, 은행과 다른 점은 개인의 거래 대상 별이라는 점)
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        
    }   

    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        // 설정된 거래 한도 보기
        return allowances[_owner][_spender]; // **
    }

    // Events ----------------------------------------------------------------
    // 직접 구현하지 않음
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    // -----------------------
    function _mint(address _supplier, uint256 _value) public returns(bool success){
        require(_supplier != address(0), "transfer to the zero address");
        balances[_supplier] += _value;
        _totalSupply += _value;
        
    }

    function _burn(address _supplier, uint256 _value) public returns (bool success){
        require(_supplier != address(0), "transfer to the zero address");
        balances[_supplier] -= _value;
        _totalSupply -= _value;
    }

}
