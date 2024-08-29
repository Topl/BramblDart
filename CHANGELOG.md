## 2.0.0-beta.2
- Contract was renamed to Template
- Codecs updated to reflect BramblSc
- TransactionBuilderApi partial updates

## 2.0.0-beta.1
- Improved GRPC channel API with new channel_factory and helpers
- Scrypt is made available via export
- Fixed various codec and json mismatches
- Proposition_template json now writes Int64 as string

## 2.0.0-beta.0
- [TSDK-657](https://topl.atlassian.net/browse/TSDK-657) Update To Mint Group, Series and Assets
- [TSDK-629](https://topl.atlassian.net/browse/TSDK-629)  Extra service kit related tests
- [TSDK-831](https://topl.atlassian.net/browse/TSDK-831) Integrate recent updates from ts/scala for beta 1
- Various fixes to validations and extra validators added  
- Improved implementation of Sha256DigestInterpreter  
- Improvements to builder API's to simplify working with the SDK 


## 2.0.0-alpha.3
- [TSDK-630] Bugfix for Language dictionary loading error
- [TSDK-651] Fixes type check causing template builder to throw errors because of an unexpected inner proposition
- [TSDK-615] [TSDK-653] Bugfixes for lock's and extra tests
- [TSDK-660] [TSDK-656] Fixes bug where extended_ed25519 key returned size of 31 instead of 32


## 2.0.0-alpha.2
- setup linter for better code quality
- WalletEntity has been renamed to WalletFellowship, Party has been renamed to Fellowship as well
- Added and optomized exports for missing brambl_dart functionality
- Made api signature changes for servicekit alpha 1


## 2.0.0-alpha.1
- Initial version
