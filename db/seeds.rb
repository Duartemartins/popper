# This file contains all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Initialize counters for summary
users_created = 0
conjectures_created = 0
refutations_created = 0
bounties_created = 0
tags_created = 0
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
      falsification_criteria: "This conjecture would be falsified if: (1) A specific investment strategy demonstrates returns exceeding the market average by at least 15% annually over a minimum 10-year period while controlling for risk factors; (2) The strategy must be documented in advance with clear rules and tested on out-of-sample data; (3) At least three independent research teams must be able to replicate the results by December 2026; (4) The strategy must account for transaction costs, market impact, and survivorship bias.",
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
      falsification_criteria: "This conjecture would be falsified if: (1) A non-biological system demonstrates at least 8 of the 10 agreed-upon markers of consciousness as defined by the Institute of Consciousness Studies by 2030; (2) The system passes a modified Turing test specifically designed to evaluate consciousness markers, administered by at least 5 independent research teams; (3) The system shows measurable physiological responses analogous to those associated with subjective experience in humans (e.g., attention patterns, response to novelty); (4) Results must be reproducible across at least 3 different hardware implementations.",
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
      falsification_criteria: "This conjecture would be falsified if: (1) Confirmed detection of at least 3 distinct technological alien civilizations by major space agencies or observatories by 2035; (2) Radio, optical, or other measurable signatures of artificial origin detected from at least 5 different star systems within 100 light-years; (3) Artifact discovery providing conclusive evidence (99% scientific consensus) of extraterrestrial visitation to our solar system; or (4) A rigorous mathematical model, validated by at least 2 independent research teams, demonstrating that our current detection methods have less than 1% probability of finding existing civilizations even if they are common.",
      status: "active",
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
      falsification_criteria: "This conjecture would be falsified if: (1) A peer-reviewed neuroscience study, replicated by at least 2 independent labs by 2028, demonstrates neurological activity that cannot be explained by prior physical causes; (2) A formal experimental protocol shows decision-making processes that violate causal closure with statistical significance of p<0.001; (3) A measurable mind-brain interaction mechanism is discovered that allows consciousness to affect neural activity without corresponding prior neural correlates; or (4) Quantum effects in the brain are definitively shown to enable free will through controlled experiments that isolate and measure these effects specifically in decision-making processes.",
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
      falsification_criteria: "This conjecture would be falsified if: (1) A purely digital AI system demonstrates general intelligence across at least 5 distinct domains (scoring 90%+ on standardized tests for each) by 2033; (2) The system can pass specialized Turing tests focused on physical reasoning without having been explicitly trained on embodied data; (3) The system demonstrates the ability to learn new physical tasks from descriptions alone with 85% accuracy when tested in simulation; (4) At least 3 independent research institutions verify these capabilities using standardized benchmarks; and (5) The system architecture and training methodology is fully documented to prove no embodied data or embodied simulation was used in its development.",
      status: "active",
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

  # Add tags to conjectures
  # Define some common tags
  tag_names = [
    "economics", "finance", "markets",
    "philosophy", "consciousness", "ai",
    "space", "astronomy", "aliens",
    "metaphysics", "free will", "determinism",
    "intelligence", "cognition", "embodiment"
  ]

  # Create tags if they don't exist
  created_tags = tag_names.map do |name|
    tag = Tag.find_or_create_by(name: name.downcase)
    if tag.persisted? && tag.previously_new_record?
      tags_created += 1
      puts "Created tag: #{name}"
    else
      puts "Tag '#{name}' already exists"
    end
    tag
  end

  # Add tags to conjectures if they exist
  if conjecture1
    # Markets Are Efficient Information Processors
    conjecture1.tags = Tag.where(name: [ "economics", "finance", "markets" ])
    puts "Added tags to conjecture: Markets Are Efficient Information Processors"
  end

  if conjecture2
    # Consciousness Requires Biological Substrate
    conjecture2.tags = Tag.where(name: [ "consciousness", "philosophy", "ai" ])
    puts "Added tags to conjecture: Consciousness Requires Biological Substrate"
  end

  if conjecture3
    # The Fermi Paradox Implies Great Filters
    conjecture3.tags = Tag.where(name: [ "space", "astronomy", "aliens" ])
    puts "Added tags to conjecture: The Fermi Paradox Implies Great Filters"
  end

  if conjecture4
    # Free Will is an Illusion
    conjecture4.tags = Tag.where(name: [ "philosophy", "free will", "determinism" ])
    puts "Added tags to conjecture: Free Will is an Illusion"
  end

  if conjecture5
    # AGI Requires Embodiment
    conjecture5.tags = Tag.where(name: [ "ai", "intelligence", "cognition", "embodiment" ])
    puts "Added tags to conjecture: AGI Requires Embodiment"
  end

  # Print summary
  puts "\nSeed data summary:"
  puts "  Users created: #{users_created}"
  puts "  Conjectures created: #{conjectures_created}"
  puts "  Refutations created: #{refutations_created}"
  puts "  Bounties created: #{bounties_created}"
  puts "  Tags created: #{tags_created}"

  if errors.any?
    puts "\nWarnings/Errors:"
    errors.each { |error| puts "  - #{error}" }
  end
rescue => e
  puts "An error occurred during seeding: #{e.message}"
  puts e.backtrace.join("\n")
end
