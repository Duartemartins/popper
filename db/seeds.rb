# This file contains all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Initialize counters for summary
users_created = 0
conjectures_created = 0
refutations_created = 0
bounties_created = 0
errors = []

begin
  # Create admin user if doesn't exist
  admin = User.find_by(email: 'admin_two@example.com')
  if admin.nil?
    admin = User.create!(
      email: 'admin_two@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
    users_created += 1
    puts "Created admin user"
  else
    puts "Admin user already exists"
  end

  # Create a regular user if doesn't exist
  user = User.find_by(email: 'user_two@example.com')
  if user.nil?
    user = User.create!(
      email: 'user_two@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
    users_created += 1
    puts "Created regular user"
  else
    puts "Regular user already exists"
  end

  # Create scientist user if doesn't exist
  scientist = User.find_by(email: 'scientist_two@example.com')
  if scientist.nil?
    scientist = User.create!(
      email: 'scientist_two@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
    users_created += 1
    puts "Created scientist user"
  else
    puts "Scientist user already exists"
  end

  # Create philosopher user if doesn't exist
  philosopher = User.find_by(email: 'philosopher@example.com')
  if philosopher.nil?
    philosopher = User.create!(
      email: 'philosopher@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
    users_created += 1
    puts "Created philosopher user"
  else
    puts "Philosopher user already exists"
  end

  # Create sample conjectures
  conjecture1 = Conjecture.find_by(title: "Markets Are Efficient Information Processors")
  if conjecture1.nil?
    conjecture1 = Conjecture.create!(
      title: "Markets Are Efficient Information Processors",
      description: "Financial markets efficiently incorporate all available information into asset prices, making it impossible to consistently achieve returns that beat the market average through skilled stock selection or market timing.",
      falsification_criteria: "Demonstrating consistently superior returns over a long period through a documented strategy would refute this conjecture. The evidence should control for risk and survivorship bias.",
      status: "active",
      user: admin
    )
    conjectures_created += 1
    puts "Created conjecture: Markets Are Efficient Information Processors"
  else
    puts "Conjecture 'Markets Are Efficient Information Processors' already exists"
  end

  conjecture2 = Conjecture.find_by(title: "Consciousness Requires Biological Substrate")
  if conjecture2.nil?
    conjecture2 = Conjecture.create!(
      title: "Consciousness Requires Biological Substrate",
      description: "Consciousness, as subjectively experienced by humans, is fundamentally dependent on biological processes and cannot emerge from non-biological systems regardless of their complexity or computational power.",
      falsification_criteria: "Creating a non-biological system that demonstrates behaviors consistent with consciousness and/or passes rigorous versions of the Turing test would refute this conjecture.",
      status: "active",
      user: user
    )
    conjectures_created += 1
    puts "Created conjecture: Consciousness Requires Biological Substrate"
  else
    puts "Conjecture 'Consciousness Requires Biological Substrate' already exists"
  end

  conjecture3 = Conjecture.find_by(title: "The Fermi Paradox Implies Great Filters")
  if conjecture3.nil?
    conjecture3 = Conjecture.create!(
      title: "The Fermi Paradox Implies Great Filters",
      description: "The absence of observable alien civilizations despite the vastness of the universe and probability of life suggests that there are one or more 'great filters' preventing the development of interstellar civilizations. These filters may be behind us (rare Earth) or ahead of us (civilizational collapse).",
      falsification_criteria: "Discovery of numerous alien civilizations or evidence of their widespread existence would falsify this conjecture. Alternatively, a mathematical proof that shows our observational methods are fundamentally flawed would also refute it.",
      status: "published",
      user: scientist
    )
    conjectures_created += 1
    puts "Created conjecture: The Fermi Paradox Implies Great Filters"
  else
    puts "Conjecture 'The Fermi Paradox Implies Great Filters' already exists"
  end

  conjecture4 = Conjecture.find_by(title: "Free Will is an Illusion")
  if conjecture4.nil?
    conjecture4 = Conjecture.create!(
      title: "Free Will is an Illusion",
      description: "What we perceive as free will is merely the experience of making choices without awareness of the deterministic neurological and environmental processes that actually cause our decisions. Our sense of agency is a useful evolutionary adaptation but does not reflect metaphysical freedom.",
      falsification_criteria: "Demonstrating the existence of decisions that cannot be explained by prior physical causes, or providing evidence for a non-physical mind that can causally influence physical events in ways that violate physical law would refute this conjecture.",
      status: "active",
      user: philosopher
    )
    conjectures_created += 1
    puts "Created conjecture: Free Will is an Illusion"
  else
    puts "Conjecture 'Free Will is an Illusion' already exists"
  end

  conjecture5 = Conjecture.find_by(title: "AGI Requires Embodiment")
  if conjecture5.nil?
    conjecture5 = Conjecture.create!(
      title: "AGI Requires Embodiment",
      description: "Artificial General Intelligence cannot emerge from purely digital systems processing symbolic information. True intelligence requires sensorimotor experience in a physical environment to develop grounded understanding of concepts and causality.",
      falsification_criteria: "Development of a purely digital system that demonstrates general intelligence across domains without having been embodied or trained on data from embodied systems would falsify this conjecture.",
      status: "draft",
      user: scientist
    )
    conjectures_created += 1
    puts "Created conjecture: AGI Requires Embodiment"
  else
    puts "Conjecture 'AGI Requires Embodiment' already exists"
  end

  # Add refutations only if they don't exist yet
  if conjecture1 && !Refutation.exists?(conjecture: conjecture1, user: user)
    begin
      Refutation.create!(
        content: "The efficient market hypothesis doesn't account for well-documented behavioral biases like loss aversion and overconfidence, which create predictable patterns in market pricing that can be exploited by systematic trading strategies.",
        conjecture: conjecture1,
        user: user
      )
      refutations_created += 1
      puts "Created refutation for conjecture1 by user"
    rescue => e
      errors << "Failed to create refutation for conjecture1 by user: #{e.message}"
    end
  else
    puts "Refutation for conjecture1 by user already exists or conjecture doesn't exist"
  end

  if conjecture2 && !Refutation.exists?(conjecture: conjecture2, user: admin)
    begin
      Refutation.create!(
        content: "This conjecture relies on a problematic definition of consciousness. If we define consciousness functionally rather than through subjective experience, we can evaluate the potential for non-biological consciousness without requiring access to subjective states.",
        conjecture: conjecture2,
        user: admin
      )
      refutations_created += 1
      puts "Created refutation for conjecture2 by admin"
    rescue => e
      errors << "Failed to create refutation for conjecture2 by admin: #{e.message}"
    end
  else
    puts "Refutation for conjecture2 by admin already exists or conjecture doesn't exist"
  end

  if conjecture1 && !Refutation.exists?(conjecture: conjecture1, user: scientist)
    begin
      Refutation.create!(
        content: "Renaissance Technologies' Medallion Fund has consistently generated returns of over 60% annually for decades, far outperforming market averages even after accounting for risk. Their systematic approach uses mathematical models to identify market inefficiencies, proving that markets are not perfectly efficient.",
        conjecture: conjecture1,
        user: scientist
      )
      refutations_created += 1
      puts "Created refutation for conjecture1 by scientist"
    rescue => e
      errors << "Failed to create refutation for conjecture1 by scientist: #{e.message}"
    end
  else
    puts "Refutation for conjecture1 by scientist already exists or conjecture doesn't exist"
  end

  if conjecture3 && !Refutation.exists?(conjecture: conjecture3, user: philosopher)
    begin
      Refutation.create!(
        content: "The Fermi Paradox assumes that interstellar travel or communication is both desirable and feasible for advanced civilizations. However, physics may impose hard limits on interstellar travel, and advanced civilizations might evolve toward post-biological existence focused inward rather than on expansion.",
        conjecture: conjecture3,
        user: philosopher
      )
      refutations_created += 1
      puts "Created refutation for conjecture3 by philosopher"
    rescue => e
      errors << "Failed to create refutation for conjecture3 by philosopher: #{e.message}"
    end
  else
    puts "Refutation for conjecture3 by philosopher already exists or conjecture doesn't exist"
  end

  if conjecture4 && !Refutation.exists?(conjecture: conjecture4, user: scientist)
    begin
      Refutation.create!(
        content: "Quantum indeterminacy at the subatomic level introduces genuine randomness into physical systems, including brains. This undermines the deterministic assumption behind the rejection of free will. If neural processes involve quantum effects, true freedom might emerge from this physical indeterminacy.",
        conjecture: conjecture4,
        user: scientist
      )
      refutations_created += 1
      puts "Created refutation for conjecture4 by scientist"
    rescue => e
      errors << "Failed to create refutation for conjecture4 by scientist: #{e.message}"
    end
  else
    puts "Refutation for conjecture4 by scientist already exists or conjecture doesn't exist"
  end

  if conjecture5 && !Refutation.exists?(conjecture: conjecture5, user: admin)
    begin
      Refutation.create!(
        content: "Recent language models demonstrate understanding across domains without embodiment. GPT-4 can reason about physical situations, social dynamics, and abstract concepts despite never having a body. This suggests that sufficient training on human-generated text can substitute for direct embodied experience.",
        conjecture: conjecture5,
        user: admin
      )
      refutations_created += 1
      puts "Created refutation for conjecture5 by admin"
    rescue => e
      errors << "Failed to create refutation for conjecture5 by admin: #{e.message}"
    end
  else
    puts "Refutation for conjecture5 by admin already exists or conjecture doesn't exist"
  end

  # Create bounties only if they don't exist yet
  if conjecture1 && !Bounty.exists?(conjecture: conjecture1, user: scientist)
    begin
      Bounty.create!(
        amount: 500,
        user: scientist,
        conjecture: conjecture1
      )
      bounties_created += 1
      puts "Created bounty for conjecture1"
    rescue => e
      errors << "Failed to create bounty for conjecture1: #{e.message}"
    end
  else
    puts "Bounty for conjecture1 already exists or conjecture doesn't exist"
  end

  if conjecture4 && !Bounty.exists?(conjecture: conjecture4, user: admin)
    begin
      Bounty.create!(
        amount: 1000,
        user: admin,
        conjecture: conjecture4
      )
      bounties_created += 1
      puts "Created bounty for conjecture4"
    rescue => e
      errors << "Failed to create bounty for conjecture4: #{e.message}"
    end
  else
    puts "Bounty for conjecture4 already exists or conjecture doesn't exist"
  end

  # Print summary
  puts "\nSeed data summary:"
  puts "  Users created: #{users_created}"
  puts "  Conjectures created: #{conjectures_created}"
  puts "  Refutations created: #{refutations_created}"
  puts "  Bounties created: #{bounties_created}"

  if errors.any?
    puts "\nWarnings/Errors:"
    errors.each { |error| puts "  - #{error}" }
  end
rescue => e
  puts "An error occurred during seeding: #{e.message}"
  puts e.backtrace.join("\n")
end
