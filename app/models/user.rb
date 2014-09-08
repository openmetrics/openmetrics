# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  username               :string(255)
#  slug                   :string(255)
#  api_token              :string(40)
#

class User < ActiveRecord::Base

  # Use username within profile url
  extend FriendlyId
  friendly_id :username, use: :slugged

  # Validations
  validates :username, presence: true,
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
  # devise reads: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
  def enable_api!
    self.update_attribute(:api_token , self.generate_api_token)
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

  def generate_api_token
    loop do
       token = Devise.friendly_token # devise token generator: 20 of a-zA-Z0-9_-
       #token = secure_digest(Time.now, (1..10).map{ rand.to_s }) # custom token generator: 40 of a-f0-9
       break token unless User.where(api_token: token).first
     end
  end

end
