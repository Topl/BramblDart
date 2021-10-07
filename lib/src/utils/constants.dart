part of 'package:brambldart/utils.dart';

const maxMnemonicValue = 2047;
const maxJS = 52;
const shortNameLimit = 8;
const blake2b256DigestSize = 32;
const modifierIdSize = 1 + blake2b256DigestSize;
const bloomFilterBytes = 256;
const defaultPurpose = 1852 | hardenedOffset;
const defaultCoinType = 7091 | hardenedOffset;
const defaultAccountIndex = 0 | hardenedOffset;

/// 0=external/payments, 1=internal/change, 2=staking
const defaultChange = 0;
const defaultChangeIndex = 0;

const defaultAddressIndex = 0;

const curvePrefix = 0x01;
const curveThresholdPrefix = 0x02;
const defaultPropositionPrefix = 0x03;

const curve25519 = 'PublicKeyCurve25519';
const ed25519 = 'PublicKeyEd25519';
const thresholdCurve25519 = 'ThresholdCurve25519';

const hardenedOffset = 0x80000000; //denoted by a single quote in chain values

const toplnet = 'Mainnet';
const toplnetFee = 1000000000;
const valhalla = 'ValhallaTestnet';
const valhallaFee = 100;
const private = 'PrivateTestnet';

const valhallaPrefix = 0x10;
const privatePrefix = 0x40;
const mainnetPrefix = 0x01;

const supportedAssetCodeVersion = 1;
const pubKeyHashByte = 0x03;
const pollingDuration = 10;
