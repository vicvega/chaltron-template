class User < ApplicationRecord
  include Chaltron::Enableable
  include Chaltron::HasRoles
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable,
         :timeoutable, :trackable, :omniauthable

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  # Only allow letter, number, underscore and punctuation.
  # see https://github.com/heartcombo/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, multiline: true

  attr_writer :login

  def login
    @login || self.username || self.email
  end

  def display_name
    self.fullname || self.username
  end

  def ldap_user?
    provider == 'ldap'
  end

  # override devise method to allow sign in with email or username
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  # override devise method to check if user account is active
  def active_for_authentication?
    super && enabled?
  end

  def inactive_message
    enabled? ? super : I18n.t('chaltron.users.inactive_message')
  end

end
