class User < ActiveRecord::Base

  # Use username within profile url
  extend FriendlyId
  friendly_id :username, use: :slugged

  # Validations
  validates :username,
            :uniqueness => {
                :case_sensitive => false
            }


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]


  #
  # Make Devise use email or username for auth, see also
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  #
  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  # Concerns
  include Trackable

  # Overwrite Devise's find_for_database_authentication method in User model
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", {:value => login.downcase}]).first
    else
      where(conditions).first
    end
  end

  # API stuff from http://www.justinbritten.com/work/2009/05/rails-api-authentication-using-restful-authentication/
  def enable_api!
    self.generate_api_token!
  end

  def disable_api!
    self.update_attribute(:api_token, nil)
  end

  def api_is_enabled?
    !self.api_token.nil?
  end


  protected

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def generate_api_token!
    self.update_attribute(:api_token, secure_digest(Time.now, (1..10).map{ rand.to_s }))
  end

end
