// SPDX-License-Identifier: MIT
//
// ________  ___       ________  ________  _________  _______   ________
//|\   __  \|\  \     |\   __  \|\   __  \|\___   ___\\  ___ \ |\   __  \
//\ \  \|\ /\ \  \    \ \  \|\  \ \  \|\  \|___ \  \_\ \   __/|\ \  \|\  \
// \ \   __  \ \  \    \ \  \\\  \ \   __  \   \ \  \ \ \  \_|/_\ \   _  _\
//  \ \  \|\  \ \  \____\ \  \\\  \ \  \ \  \   \ \  \ \ \  \_|\ \ \  \\  \|
//   \ \_______\ \_______\ \_______\ \__\ \__\   \ \__\ \ \_______\ \__\\ _\
//    \|_______|\|_______|\|_______|\|__|\|__|    \|__|  \|_______|\|__|\|__|
//                             .:.
//                            .#++.
//                            -#*+-
//                   :====-.. :%#*.  .----:.
//                 :==----=--------=+==------.
//                -==-----:==-----=+==----::::.
//               .==--+##*--==----=++-=*#*-:::-.
//               -+===+@@%+===------==+@@@*----:
//               +++====++=====+===----=-====-=:
//              .**+++++**++++++++++++=---=====-
//              =+++++****###%%%%%%###*++--::::-.
//             -+++++***%@@@@@@@@@@@@@@%#*=---:--.
//            .+++=+#**%@@@@@@@@@@@@@@@@@#*==----:
//            =++++##**##%%@@@@%%@@@@@@@@%++==----.
//      .:::--+*+++##*+*==*##########**#@#+++=----::..
//  -****##%@@%*++=*%#+=*@%%##########%@%*+**=---+@@%#*=---.
//  :#%%%%*-.  .**++*%#++*@@@@@@@@@@%%%*++**====-  +%@@@%%%#.
//              .=#***%%#*++++*###*+++++*#*++*#-      ..-=-.
//                 -%%##%@%#*+++++++*#%@%##%#.
//                   .:*#%%@@@@@@@@@%@@%#+:
//                         ..::---::..
// longzai, such a j j
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BloaterConnect is ERC20, Ownable {
    uint256 public constant MAX_HOLDING_AMOUNT = 5_000_000_000 * (10 ** 18);
    bool public isFirstHour = true;
    bool public isLiquidityPoolLive = false;

    constructor() ERC20("Bloater Connect", "BLOAT") Ownable(msg.sender) {
        _mint(msg.sender, 500_000_000_000 * 10 ** decimals());
    }

    function toggleLiquidityPoolToTrue() external onlyOwner {
        isLiquidityPoolLive = true;
    }

    function toggleFirstHourToFalse() external onlyOwner {
        isFirstHour = false;
    }

    /*
     * @notice Enforce a limit of 5 billion token transfers/trading per transaction & per wallet during the first hour.
     * @dev Exclude enforcement during the initial minting of tokens and liquidity pool creation.
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        //Bootstrapping phase: Transfer only allows for minting and setting LP from the owner
        if (!isLiquidityPoolLive) {
            require((from == owner() || to == owner()), "Bootstraping phrase");
        }

        super._update(from, to, value);
        
        //First hour phase: Enforce limit on trade and holdings
        if (isFirstHour && isLiquidityPoolLive) {
            require(
                value <= MAX_HOLDING_AMOUNT,
                "Trading or transfer is limited to 5 billion BLOATERCON during the first hour."
            );

            require(
                balanceOf(to) <= MAX_HOLDING_AMOUNT,
                "Wallets are limited to holding 5 billion BLOATERCON during the first hour."
            );
        }
    }
}
