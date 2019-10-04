#!/bin/bash
pushd data/db
rm .data_loaded .dba_pwd_set virtuoso{-temp.db,.db,.log,.pxa,.trx}
popd
