class User < ApplicationRecord
  VALID_EMAIL_REGEX = Settings.validations.users.email_regex
  USERS_PARAMS_PERMIT = %i(name email password password_confirmation).freeze

  attr_accessor :remember_token, :activation_token

  validates :name, presence: true,
            length: {maximum: Settings.validations.users.name_max_length}
  validates :email, presence: true,
            length: {maximum: Settings.validations.users.email_max_length},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: true}
  validates :password, presence: true,
            length: {minimum: Settings.validations.users.password_min_length},
            allow_nil: true

  has_secure_password

  before_save :email_downcase
  before_create :create_activation_digest

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember_digest
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update remember_digest: nil
  end

  def update_activation
    update activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def email_downcase
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
