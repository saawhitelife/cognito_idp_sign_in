# cognito_idp_sign_in Example

This is an example Flutter application demonstrating how to use the `cognito_idp_sign_in` package.

## Overview

This example app shows how to:
- Configure and initialize `CognitoIdpSignIn`
- Sign in with Cognito Identity Provider (IdP)
- Handle authentication errors
- Display authentication results

## Getting Started

1. Make sure you have Flutter installed and set up
2. Navigate to this directory:
   ```bash
   cd packages/cognito_idp_sign_in/example
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Configure your Cognito settings in `lib/main.dart`:
   - Update `hostedUiDomain`
   - Update `clientId`
   - Update `redirectUri` (use `Uri.parse('yourapp://')` for mobile or full URL for web)
   - Configure other options as needed
5. Run the app:
   ```bash
   flutter run
   ```

## Package Documentation

For more information about the `cognito_idp_sign_in` package, see the main package documentation.
