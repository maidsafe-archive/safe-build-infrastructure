#!/usr/bin/env bash

cd safe_client_libs
mkdir -p target/deploy
echo "===============================" >> packaging.log
echo "Packaging Safe App with Mock" >> packaging.log
echo "===============================" >> packaging.log
( time ./scripts/package.rs --lib --name safe_app -d target/deploy --mock ) 2>&1 | tee -a packaging.log
echo "===============================" >> packaging.log
echo "Packaging Safe App" >> packaging.log
echo "===============================" >> packaging.log
( time ./scripts/package.rs --lib --name safe_app -d target/deploy ) 2>&1 | tee -a packaging.log
echo "======================================" >> packaging.log
echo "Packaging Safe Authenticator with Mock" >> packaging.log
echo "======================================" >> packaging.log
( time ./scripts/package.rs --lib --name safe_authenticator -d target/deploy --mock ) 2>&1 | tee -a packaging.log
echo "======================================" >> packaging.log
echo "Packaging Safe Authenticator" >> packaging.log
echo "======================================" >> packaging.log
( time ./scripts/package.rs --lib --name safe_authenticator -d target/deploy ) 2>&1 | tee -a packaging.log
