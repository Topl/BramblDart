const SEED_SIZE = 32;
const MAX_MNEMONIC_VALUE = 2047;
const MAX_JS = 52;
const SHORT_NAME_LIMIT = 8;
const BLAKE2B_256_DIGEST_SIZE = 32;
const MODIFIER_ID_SIZE = 1 + BLAKE2B_256_DIGEST_SIZE;
const BLOOM_FILTER_BYTES = 256;
const DEFAULT_PURPOSE = 1852 | HARDENED_OFFSET;
const DEFAULT_COIN_TYPE = 7091 | HARDENED_OFFSET;
const DEFAULT_ACCOUNT_INDEX = 0 | HARDENED_OFFSET;

/// 0=external/payments, 1=internal/change, 2=staking
const DEFAULT_CHANGE = 0;
const DEFAULT_ADDRESS_INDEX = 0;

const HARDENED_OFFSET = 0x80000000; //denoted by a single quote in chain values

const TOPLNET = 'Mainnet';
const TOPLNET_FEE = 1000000000;
const VALHALLA = 'ValhallaTestnet';
const VALHALLA_FEE = 100;
const PRIVATE = 'PrivateTestnet';
