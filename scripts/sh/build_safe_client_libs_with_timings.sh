#!/usr/bin/env bash

git clone https://github.com/maidsafe/safe_client_libs.git 
cd safe_client_libs
echo "===============================" >> build.log
echo "Building Safe Core" >> build.log
echo "===============================" >> build.log
( time ./scripts/build-real-core ) 2>&1 | tee -a build.log
echo "========================================" >> build.log
echo "Building Safe Authenticator and Safe App" >> build.log
echo "========================================" >> build.log
( time ./scripts/build-real ) 2>&1 | tee -a build.log
echo "======================" >> build.log
echo "Building Mock Versions" >> build.log
echo "======================" >> build.log
( time ./scripts/build-mock ) 2>&1 | tee -a build.log
echo "=========================" >> build.log
echo "Test binary compatibility" >> build.log
echo "=========================" >> build.log
( time ./scripts/test-binary ) 2>&1 | tee -a build.log
echo "==================" >> build.log
echo "Tests with mocking" >> build.log
echo "==================" >> build.log
( time ./scripts/test-mock ) 2>&1 | tee -a build.log
echo "=================" >> build.log
echo "Integration Tests" >> build.log
echo "=================" >> build.log
( time ./scripts/test-integration ) 2>&1 | tee -a build.log
