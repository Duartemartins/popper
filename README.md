# Popper

Popper is a Ruby on Rails 8 web application for managing and incentivizing conjectures and refutations. The platform enables users to propose conjectures, refute them, and place bounties on their resolution. The app integrates with the Ethereum blockchain, allowing users to interact with smart contracts and manage bounties using their Ethereum wallets via MetaMask. MetaMask is required for users to sign transactions and manage funds securely on Ethereum.

## Requirements

- **Ruby**: 3.3.0
- **Rails**: ~> 8.0.2
- **Database**: SQLite3 (default)
- **Kamal** (for containerized development and deployment)

## Setup

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd popper
   ```

2. **Install dependencies:**
   ```sh
   bundle install
   ```

3. **Set up the database:**
   ```sh
   bin/rails db:setup
   # or, if you want to create and migrate separately:
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. **Environment variables:**
   - Copy `.env.example` to `.env` and fill in any required secrets or API keys.
   - The application uses environment variables for configuration. See `.env` for details.

## Running the Application

- **Locally:**
  ```sh
  rails assets:precompile && bin/dev
  ```

- **With Kamal:**
  Kamal 2 is used for containerized deployments and orchestration. To build and run the app using Kamal:
  ```sh
  kamal setup
  kamal deploy
  ```
  See `config/deploy.yml` for Kamal deployment configuration.

## MetaMask & Ethereum Integration

- Popper requires users to connect their MetaMask wallet to interact with Ethereum smart contracts.
- Bounties and payments are managed on the Ethereum blockchain.
- MetaMask is used for authentication and transaction signing.
- Ensure MetaMask is installed in your browser and connected to the correct Ethereum network.

## Running Tests

- The test suite is written using **Minitest**, the default testing framework for Rails.
- **All tests:**
  ```sh
  bin/rails test
  ```
- **System tests:**
  ```sh
  bin/rails test:system
  ```
- **Test coverage:** The test suite currently covers the core models and controllers, including user authentication, conjecture and refutation logic, bounty management, and Ethereum integration. (For precise coverage percentage, please run a coverage tool such as SimpleCov.)

## Deployment

- The app is ready for deployment with Docker and supports Kamal for zero-downtime deploys.
- See `Dockerfile` and `config/deploy.yml` for container and deployment configuration.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin my-feature`)
5. Create a new Pull Request

## License

This project is licensed under the Apache License 2.0. See the `LICENSE` file for details.

---

For more details, see the inline documentation and comments in the codebase.
