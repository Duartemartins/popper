# This file contains all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user
admin = User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password'
)

# Create a regular user
user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password'
)

# Create sample conjectures
conjecture1 = Conjecture.create!(
  title: "Markets Are Efficient Information Processors",
  description: "Financial markets efficiently incorporate all available information into asset prices, making it impossible to consistently achieve returns that beat the market average through skilled stock selection or market timing.",
  falsification_criteria: "Demonstrating consistently superior returns over a long period through a documented strategy would refute this conjecture. The evidence should control for risk and survivorship bias.",
  status: "active",
  user: admin
)

conjecture2 = Conjecture.create!(
  title: "Consciousness Requires Biological Substrate",
  description: "Consciousness, as subjectively experienced by humans, is fundamentally dependent on biological processes and cannot emerge from non-biological systems regardless of their complexity or computational power.",
  falsification_criteria: "Creating a non-biological system that demonstrates behaviors consistent with consciousness and/or passes rigorous versions of the Turing test would refute this conjecture.",
  status: "active",
  user: user
)

# Add some refutations
Refutation.create!(
  content: "The efficient market hypothesis doesn't account for well-documented behavioral biases like loss aversion and overconfidence, which create predictable patterns in market pricing that can be exploited by systematic trading strategies.",
  conjecture: conjecture1,
  user: user
)

Refutation.create!(
  content: "This conjecture relies on a problematic definition of consciousness. If we define consciousness functionally rather than through subjective experience, we can evaluate the potential for non-biological consciousness without requiring access to subjective states.",
  conjecture: conjecture2,
  user: admin
)

puts "Seed data created successfully!"
