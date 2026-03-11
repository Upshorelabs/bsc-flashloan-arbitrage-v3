// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20{
    function balanceOf(address account) external view returns(uint);
    function transfer(address recipient,uint amount) external returns(bool);
    function approve(address spender,uint amount) external returns(bool);
}

interface IRouter{
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns(uint[] memory amounts);
}

interface IFlashLoanProvider{
    function flashLoan(
        address receiver,
        address token,
        uint amount,
        bytes calldata params
    ) external;
}

contract FlashLoanArbitrageV3{

    address public owner;
    address public profitWallet;

    constructor(address _profitWallet){
        owner = msg.sender;
        profitWallet = _profitWallet;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"Not owner");
        _;
    }

    function startArbitrage(
        address flashLoanProvider,
        address tokenA,
        uint amount,
        address router1,
        address router2,
        address tokenB
    ) external onlyOwner{

        bytes memory data = abi.encode(router1,router2,tokenA,tokenB);

        IFlashLoanProvider(flashLoanProvider).flashLoan(
            address(this),
            tokenA,
            amount,
            data
        );
    }

    function executeOperation(
        address token,
        uint amount,
        uint fee,
        bytes calldata params
    ) external{

        (address router1,address router2,address tokenA,address tokenB) =
        abi.decode(params,(address,address,address,address));

        address ; // fixed: declare path array

        // First swap: tokenA -> tokenB
        IERC20(tokenA).approve(router1,amount);
        path[0] = tokenA;
        path[1] = tokenB;

        IRouter(router1).swapExactTokensForTokens(
            amount,
            1,
            path,
            address(this),
            block.timestamp
        );

        uint tokenBBalance = IERC20(tokenB).balanceOf(address(this));

        // Second swap: tokenB -> tokenA
        IERC20(tokenB).approve(router2,tokenBBalance);
        path[0] = tokenB;
        path[1] = tokenA;

        IRouter(router2).swapExactTokensForTokens(
            tokenBBalance,
            1,
            path,
            address(this),
            block.timestamp
        );

        // Repay flash loan
        uint totalDebt = amount + fee;
        IERC20(tokenA).approve(msg.sender,totalDebt);

        // Send profit to profitWallet
        uint balanceAfter = IERC20(tokenA).balanceOf(address(this));
        if(balanceAfter > totalDebt){
            uint profit = balanceAfter - totalDebt;
            IERC20(tokenA).transfer(profitWallet,profit);
        }
    }

    function withdrawToken(address token) external onlyOwner{
        uint balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(profitWallet,balance);
    }

    function updateProfitWallet(address newWallet) external onlyOwner{
        profitWallet = newWallet;
    }

}
