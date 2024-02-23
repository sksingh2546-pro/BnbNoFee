// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "uniswap-v2-contract/contracts/uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol";
import "uniswap-v2-contract/contracts/uniswap-v2-core/interfaces/IUniswapV2Factory.sol";
import "uniswap-v2-contract/contracts/uniswap-v2-core/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BuyContract is OwnableUpgradeable {
    // Address of the Uniswap v2 router
    address public UNISWAP_V2_ROUTER;

    // Address of WETH token
    address public WETH;


    constructor() {
        _disableInitializers();
    }

    modifier ZeroAddress(address _account) {
        require(_account != address(0), "BC:Invalid address");
        _;
    }
    modifier ZeroAmount(uint256 _amount) {
        require(_amount != 0, "BC:Invalid Amount");
        _;
    }

    event TokensSwapped(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        address indexed to
    );

    /**
     * @dev Initializes the contract with the specified parameters.
     * @param _router The address of the Uniswap router.
     * @param _Weth The address of the WETH (Wrapped Ether) token.
     */

    function initialize(
        address _router,
        address _Weth
    ) public initializer {
    
        UNISWAP_V2_ROUTER = _router;
        WETH = _Weth;
        __Ownable_init();
    }

    /**
     * @dev Swaps ETH for a specified token with fee.
     * @param _tokenOut The address of the token to receive in the swap.
     * @param _amountOutMin The minimum amount of `_tokenOut` expected to receive.
     * @param _to The address to receive the swapped tokens.
     */

    function swapWithFeeBuy(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to
    ) external payable ZeroAddress(_to) ZeroAmount(_amountOutMin) {
        require(msg.value > 0, "BC:Invalid ETH Amount");
        // Construct the token swap path
        address[] memory path;

        path = new address[](2);
        path[0] = WETH;
        path[1] = _tokenOut;

        uint256 _amountOut = IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactETHForTokens{value: msg.value}(
            _amountOutMin,
            path,
            _to,
            block.timestamp
        )[0];

        emit TokensSwapped(
            WETH, // ETH address
            _tokenOut,
            msg.value,
            _amountOut,
            _to
        );
    }

    /**
     * @dev Swaps a specified token for ETH with fee.
     * @param _tokenIn The address of the token to swap.
     * @param _amountIn The amount of `_tokenIn` to swap.
     * @param _amountOutMin The minimum amount of ETH expected to receive.
     * @param _to The address to receive the swapped ETH.
     */

    function swapWithFeeSell(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    )
        external
        ZeroAddress(_to)
        ZeroAmount(_amountIn)
        ZeroAmount(_amountOutMin)
    {
        // Construct the token swap path
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = WETH;

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        uint256 amount = IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactTokensForETH(
                _amountIn,
                _amountOutMin,
                path,
                address(this),
                block.timestamp
            )[1];

        (bool success, ) = _to.call{value: amount}("");
        require(success, "ETH transfer failed To User");

        emit TokensSwapped(
            _tokenIn,
            WETH, // ETH address
            _amountIn,
            amount,
            _to
        );
    }

    /**
     * @dev Swaps a specified token for ETH on Uniswap, and pays taxes to maintainer, platform, and the recipient.
     * @param _tokenIn The address of the token to swap.
     * @param _to The address to receive the swapped ETH.
     */

    function quickSwapWithFeeSell(
        address _tokenIn,
        address _to
    ) external ZeroAddress(_to) {
        // Construct the token swap path
        uint256 _amountIn = IERC20(_tokenIn).balanceOf(msg.sender);
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = WETH;

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        uint256 amount = IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactTokensForETH(
                _amountIn,
                0,
                path,
                address(this),
                block.timestamp
            )[1];

        (bool success, ) = _to.call{value: amount}("");
        require(success, "ETH transfer failed To User");

        emit TokensSwapped(
            _tokenIn,
            WETH, // ETH address
            _amountIn,
            amount,
            _to
        );
    }

    /**
     * @dev Swaps ETH with a specified token on Uniswap, and pays taxes to maintainer and platform.
     * @param _tokenOut The address of the token to receive in the swap.
     * @param _amountOutMin The minimum amount of tokens that must be received in the swap.
     * @param _to The address to receive the swapped tokens.
     */

    function swapWithBuyTaxToken(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to
    ) external payable ZeroAddress(_to) ZeroAmount(_amountOutMin) {
        require(msg.value > 0, "BC:Invalid ETH Amount");
        // Construct the token swap path
        address[] memory path;

        path = new address[](2);
        path[0] = WETH;
        path[1] = _tokenOut;

        IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(_amountOutMin, path, _to, block.timestamp);
        uint amount = IUniswapV2Router02(UNISWAP_V2_ROUTER).getAmountsOut(
            msg.value,
            path
        )[0];

        emit TokensSwapped(
            WETH, // ETH address
            _tokenOut,
            msg.value,
            amount,
            _to
        );
    }

    /**
     * @dev Swaps a specified token for ETH on Uniswap, and pays taxes to maintainer, platform, and the recipient.
     * @param _tokenIn The address of the token to swap.
     * @param _amountIn The amount of tokens to swap.
     * @param _amountOutMin The minimum amount of ETH that must be received in the swap.
     * @param _to The address to receive the swapped ETH.
     */

    function swapWithSellTaxToken(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to,
        uint _afterTax
    )
        external
        ZeroAddress(_to)
        ZeroAmount(_amountIn)
        ZeroAmount(_amountOutMin)
    {
        // Construct the token swap path
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = WETH;

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                IERC20(_tokenIn).balanceOf(address(this)),
                _amountOutMin,
                path,
                address(this),
                block.timestamp
            );

        (bool success, ) = _to.call{value: _afterTax}("");
        require(success, "ETH transfer failed To User");

        emit TokensSwapped(
            _tokenIn,
            WETH, // ETH address
            _amountIn,
            _afterTax,
            _to
        );
    }

    /**
     * @dev Swaps a specified token for ETH on Uniswap, and pays taxes to maintainer, platform, and the recipient.
     * @param _tokenIn The address of the token to swap.
     * @param _to The address to receive the swapped ETH.
     */

    function quickSwapWithSellTaxToken(
        address _tokenIn,
        address _to,
        uint _afterTax
    ) external ZeroAddress(_to) {
        // Construct the token swap path
        uint256 _amountIn = IERC20(_tokenIn).balanceOf(msg.sender);
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = WETH;

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                IERC20(_tokenIn).balanceOf(address(this)),
                0,
                path,
                address(this),
                block.timestamp
            );

        (bool success, ) = _to.call{value: _afterTax}("");
        require(success, "ETH transfer failed To User");

        emit TokensSwapped(
            _tokenIn,
            WETH, // ETH address
            _amountIn,
            _afterTax,
            _to
        );
    }

    /**
     * Get the minimum amount of token Out for a given token In and amount In
     * @param _tokenIn The address of the token to trade out of
     * @param _tokenOut The address of the token to receive in the trade
     * @param _amountIn The amount of tokens to send in
     * @return The minimum amount of tokens expected to receive
     */
    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external view returns (uint256) {
        // Construct the token swap path
        address[] memory path;
        path = new address[](2);
        if (_tokenIn == WETH) {
            path[0] = WETH;
            path[1] = _tokenOut;
        } else {
            path[0] = _tokenOut;
            path[1] = WETH;
        }

        // Get the minimum amount of token Out
        uint256[] memory amountOutMins = IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .getAmountsOut(_amountIn, path);
        return amountOutMins[path.length - 1];
    }

    receive() external payable {
        // React to receiving ether
    }

    function withdrawEther(
        address payable recipient,
        uint256 amount
    ) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        require(
            address(this).balance >= amount,
            "Insufficient balance in the contract"
        );

        recipient.transfer(amount);
    }
}
