# WineProvenance - Specialty Wine Provenance Tracker

A blockchain-based specialty wine provenance tracking and sommelier verification system built on Stacks, ensuring transparency and authenticity in fine wine markets from vineyard to cellar.

## Overview

WineProvenance enables vintners to register their specialty wine bottles with detailed vineyard information while allowing certified sommeliers to authenticate quality, creating trust and transparency in the fine wine market.

## Features

- Wine bottle registration with varietal and vineyard details
- Vineyard details and vintage year tracking
- Quality authentication by authorized sommeliers
- Vintner cellar management and bottle tracking
- Comprehensive input validation and security measures

## Smart Contract Functions

### Public Functions
- `register-wine-sommelier`: Register authorized wine sommeliers
- `register-wine-bottle`: Register new wine bottles with vineyard data
- `authenticate-wine-quality`: Authenticate quality by authorized sommeliers

### Read-Only Functions
- `get-wine-bottle`: Retrieve wine bottle information
- `get-vintner-cellar`: Get vintner's wine bottle cellar
- `is-wine-sommelier`: Check wine sommelier authorization status

## Usage

Deploy the contract with a contract steward account. Register wine sommeliers, then vintners can register their wine bottles and sommeliers can authenticate quality.

## Security

- Contract steward access control for sommelier registration
- Comprehensive input validation for all wine bottle parameters
- Principal validation to prevent unauthorized access
- Cellar capacity limits for system performance