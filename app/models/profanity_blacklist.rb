# app/models/profanity_blacklist.rb
# A single source of truth for serious profanity filtering

module ProfanityBlacklist
  SERIOUS_PROFANITIES = %w[
    fuck shit cunt bitch bastard asshole motherfucker dick pussy nigger faggot slut whore
    cock cocksucker twat spic chink kike wop gook dyke
  ].freeze
end
