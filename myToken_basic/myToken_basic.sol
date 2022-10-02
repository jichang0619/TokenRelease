// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

// Coded by JichangKim 


// https://wizard.openzeppelin.com/

/*
1. 토큰 이미지 올리는 방법 -> 클레이튼에서 올려줘야 함 -> 확인 필요
2. 거래하려면 ? -> 클레이스왑 스왑 풀 -> 5~6천만원 정도.. 넣어놓아야함
3. Staking 서비스
4. 토큰 거래할 때 세금 : Transfer Function 에서 수정 (원작자한테...몇 퍼센트)
*/

// Mintable 또 하는 토큰 economics 에 의해 계속 늘어날 수 있는
// EVM Version : istanbul(baobab)

// SmartContract : 0x3F8F1a2e1d19b049Efc3C990c34496548661081b
// Owner : 0xb2f8c60b26a53Ae960536333311CB4a04f519084


pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "./Context.sol";

contract MyToken is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    // name, symbol 변경 불가
    constructor() {
        _name = "myToken";
        _symbol = "MTK";
        _mint(msg.sender, 10000000 * 10 ** decimals()); // 발행량 * 10^18 decimals() return 18 
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // 잔액 : account 에 있는 토큰 리턴.
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    // <owner> 가 <to> 에게 <amount> 만큼 Token 전달. _msgSender() 는 Context.sol 에 정의 되어 있는 함수 리턴 값.
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    // 허용 : 위에 명시된 mapping 에 있는 값 리턴, _approve 함수에서 _allowance 값 적어줌. 잔고 관리 느낌
    // 만약 20 개 중 8개 인출했다면 12개가 출력될거다... 왜 갯수가 안바뀌지???
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    // 승인 : 받는 사람 주소에 대한 승인 한도를 설정! 그 사람에게 과도하게 많이 나가는 것을 막을 수 있음
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    // 일반 사용자가 토큰을 전송
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount); // 전송하면 Allowance 갯수 바꾸어 줘야함
        _transfer(from, to, amount);
        return true;
    }

    /*
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    */

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address"); //주소가 0 이면 에러
        require(to != address(0), "ERC20: transfer to the zero address"); //주소가 0 이면 에러

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount; // 보낸 사람 잔고는 감소
        }
        _balances[to] += amount; // 받은 사람 잔고는 증가

        emit Transfer(from, to, amount); // IERC20 에 Event 존재..결과 출력

        _afterTokenTransfer(from, to, amount);
    }

 
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    // 토큰 소각 기능 extensions/ERC20Burnable.sol
    
    /*
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    */

    // _allowance 에다가 mapping 하는 함수 
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    // 아무것도 리턴 하지 않는 함수
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    // 아무것도 리턴 하지 않는 함수
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}