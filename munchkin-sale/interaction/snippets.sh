PEM_FILE="../wallet-owner.pem"
MUNCHKIN_SALE_CONTRACT="output/munchkin-sale.wasm"

PROXY_ARGUMENT="--proxy=https://api.elrond.com"
CHAIN_ARGUMENT="--chain=1"

build_munchkin_sale() {
    (set -x; erdpy --verbose contract build "$MUNCHKIN_SALE_CONTRACT")
}

deploy_munchkin_sale() {
    local MAX_AMOUNT=100000000000000000000
    local MIN_AMOUNT=1000000000000000
    local INITIAL_PRICE=5000000000000000
    local TOKEN_ID=0x4D554E43484B494E2D333836356536

    
    local OUTFILE="out.json"
    (set -x; erdpy contract deploy --bytecode="$MUNCHKIN_SALE_CONTRACT" \
        --pem="$PEM_FILE" \
        $PROXY_ARGUMENT $CHAIN_ARGUMENT \
        --outfile="$OUTFILE" --recall-nonce --gas-limit=60000000 \
        --arguments ${MAX_AMOUNT} ${MIN_AMOUNT} ${INITIAL_PRICE} ${TOKEN_ID} --send \
        || return)

    local RESULT_ADDRESS=$(erdpy data parse --file="$OUTFILE" --expression="data['emitted_tx']['address']")
    local RESULT_TRANSACTION=$(erdpy data parse --file="$OUTFILE" --expression="data['emitted_tx']['hash']")

    echo ""
    echo "Deployed contract with:"
    echo "  \$RESULT_ADDRESS == ${RESULT_ADDRESS}"
    echo "  \$RESULT_TRANSACTION == ${RESULT_TRANSACTION}"
    echo ""
}

number_to_u64() {
    local NUMBER=$1
    printf "%016x" $NUMBER
}
