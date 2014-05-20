# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      default(""), not null
#  encrypted_password       :string(255)      default(""), not null
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  name                     :string(255)
#  admin                    :boolean          default(FALSE), not null
#  projects_limit           :integer          default(10)
#  skype                    :string(255)      default(""), not null
#  linkedin                 :string(255)      default(""), not null
#  twitter                  :string(255)      default(""), not null
#  authentication_token     :string(255)
#  theme_id                 :integer          default(1), not null
#  bio                      :string(255)
#  failed_attempts          :integer          default(0)
#  locked_at                :datetime
#  extern_uid               :string(255)
#  provider                 :string(255)
#  username                 :string(255)
#  can_create_group         :boolean          default(TRUE), not null
#  can_create_team          :boolean          default(TRUE), not null
#  state                    :string(255)
#  color_scheme_id          :integer          default(1), not null
#  notification_level       :integer          default(1), not null
#  password_expires_at      :datetime
#  created_by_id            :integer
#  last_credential_check_at :datetime
#  avatar                   :string(255)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  unconfirmed_email        :string(255)
#  hide_no_ssh_key          :boolean          default(FALSE)
#  website_url              :string(255)      default(""), not null
#

require 'carrierwave/orm/activerecord'
require 'file_size_validator'

class User < ActiveRecord::Base
  default_value_for :admin, false
  default_value_for :can_create_group, true
  default_value_for :can_create_team, false
  default_value_for :hide_no_ssh_key, false

  devise :database_authenticatable, :token_authenticatable, :lockable, :async,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :confirmable, :registerable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :bio, :name, :username,
                  :skype, :linkedin, :twitter, :website_url, :color_scheme_id, :theme_id, :force_random_password,
                  :extern_uid, :provider, :password_expires_at, :avatar, :hide_no_ssh_key,
                  as: [:default, :admin]

  attr_accessible :projects_limit, :can_create_group,
                  as: :admin

  attr_accessor :force_random_password

  # Virtual attribute for authenticating by either username or email
  attr_accessor :login

  # Add login to attr_accessible
  attr_accessible :login


  #
  # Relations
  #

  # Profile
  has_many :keys, dependent: :destroy
  has_many :emails, dependent: :destroy

  # Projects
  has_many :snippets,                 dependent: :destroy, foreign_key: :user_id, class_name: "Snippet"
  # has_many :groups_projects,          through: :groups, source: :projects
  # has_many :personal_projects,        through: :namespace, source: :projects
  # has_many :posts,                   dependent: :destroy, foreign_key: :user_id
  has_many :events,                   dependent: :destroy, foreign_key: :user_id,   class_name: "Event"
  has_many :recent_events, -> { order "id DESC" }, foreign_key: :user_id,   class_name: "Event"

  has_many :services


  #
  # Validations
  #
  validates :name, presence: true
  validates :email, presence: true, email: {strict_mode: true}, uniqueness: true
  validates :bio, length: { maximum: 255 }, allow_blank: true
  validates :extern_uid, allow_blank: true, uniqueness: {scope: :provider}
  validates :projects_limit, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :username, presence: true, uniqueness: { case_sensitive: false },
            exclusion: { in: Gitlab::Blacklist.path },
            format: { with: Gitlab::Regex.username_regex,
                      message: "only letters, digits & '_' '-' '.' allowed. Letter should be first" }

  validates :notification_level, inclusion: { in: Notification.notification_levels }, presence: true
  validate :avatar_type, if: ->(user) { user.avatar_changed? }
  validate :unique_email, if: ->(user) { user.email_changed? }
  validates :avatar, file_size: { maximum: 100.kilobytes.to_i }

  before_validation :generate_password, on: :create
  before_validation :sanitize_attrs

  before_save :ensure_authentication_token

  alias_attribute :private_token, :authentication_token

  state_machine :state, initial: :active do
    after_transition any => :blocked do |user, transition|
      # Remove user from all projects and
      user.users_projects.find_each do |membership|
        # skip owned resources
        next if membership.project.owner == user

        return false unless membership.destroy
      end

      # Remove user from all groups
      user.users_groups.find_each do |membership|
        # skip owned resources
        next if membership.group.last_owner?(user)

        return false unless membership.destroy
      end
    end

    event :block do
      transition active: :blocked
    end

    event :activate do
      transition blocked: :active
    end
  end

  mount_uploader :avatar, AttachmentUploader

  # Scopes
  scope :admins, -> { where(admin:  true) }
  scope :blocked, -> { with_state(:blocked) }
  scope :active, -> { with_state(:active) }
  scope :alphabetically, -> { order('name ASC') }
  scope :without_projects, -> { where('id NOT IN (SELECT DISTINCT(user_id) FROM users_projects)') }
  scope :ldap, -> { where(provider:  'ldap') }

  #
  # Class methods
  #
  class << self
    # Devise method overridden to allow sign in with email or username
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
      else
        where(conditions).first
      end
    end

    def find_for_commit(email, name)
      # Prefer email match over name match
      User.where(email: email).first ||
        User.joins(:emails).where(emails: { email: email }).first ||
        User.where(name: name).first
    end

    def filter filter_name
      case filter_name
      when "admins"; self.admins
      when "blocked"; self.blocked
      when "wop"; self.without_projects
      else
        self.active
      end
    end

    def search query
      where("lower(name) LIKE :query OR lower(email) LIKE :query OR lower(username) LIKE :query", query: "%#{query.downcase}%")
    end

    def by_username_or_id(name_or_id)
      where('users.username = ? OR users.id = ?', name_or_id.to_s, name_or_id.to_i).first
    end

    def build_user(attrs = {}, options= {})
      if options[:as] == :admin
        User.new(defaults.merge(attrs.symbolize_keys), options)
      else
        User.new(attrs, options).with_defaults
      end
    end

    def defaults
      {
        projects_limit: Gitlab.config.gitlab.default_projects_limit,
        can_create_group: Gitlab.config.gitlab.default_can_create_group,
        theme_id: Gitlab.config.gitlab.default_theme
      }
    end
  end

  #
  # Instance methods
  #

  def to_param
    username
  end

  def notification
    @notification ||= Notification.new(self)
  end

  def generate_password
    if self.force_random_password
      self.password = self.password_confirmation = Devise.friendly_token.first(8)
    end
  end

  def namespace_uniq
    namespace_name = self.username
    if Namespace.find_by(path: namespace_name)
      self.errors.add :username, "already exists"
    end
  end

  def avatar_type
    unless self.avatar.image?
      self.errors.add :avatar, "only images allowed"
    end
  end

  def unique_email
    self.errors.add(:email, 'has already been taken') if Email.exists?(email: self.email)
  end


  # Services user has access to
  def owned_services
    @owned_services ||= begin
                          Service.where(user_id: self.id)
                        end
  end

  # Team membership in authorized projects
  def tm_in_authorized_projects
    UsersProject.where(project_id: authorized_projects.map(&:id), user_id: self.id)
  end

  def is_admin?
    admin
  end

  def require_ssh_key?
    keys.count == 0
  end

  def can_change_username?
    Gitlab.config.gitlab.username_changing_enabled
  end

  def can_create_project?
    projects_limit_left > 0
  end

  def can_create_group?
    can?(:create_group, nil)
  end

  def abilities
    @abilities ||= begin
                     abilities = Six.new
                     abilities << Ability
                     abilities
                   end
  end

  def can_select_namespace?
    several_namespaces? || admin
  end

  def can? action, subject
    abilities.allowed?(self, action, subject)
  end

  def first_name
    name.split.first unless name.blank?
  end

  def cared_merge_requests
    MergeRequest.cared(self)
  end

  def projects_limit_left
    projects_limit - 0
  end

  def projects_limit_percent
    return 100 if projects_limit.zero?
    (personal_projects.count.to_f / projects_limit) * 100
  end

  def recent_push project_id = nil
    # Get push events not earlier than 2 hours ago
    events = recent_events.code_push.where("created_at > ?", Time.now - 2.hours)
    events = events.where(project_id: project_id) if project_id

    # Take only latest one
    events = events.recent.limit(1).first
  end

  def projects_sorted_by_activity
    authorized_projects.sorted_by_activity
  end

  def several_namespaces?
    owned_groups.any?
  end

  def namespace_id
    namespace.try :id
  end

  def name_with_username
    "#{name} (#{username})"
  end

  def tm_of(project)
    project.team_member_by_id(self.id)
  end

  def already_forked? project
    !!fork_of(project)
  end

  def fork_of project
    links = ForkedProjectLink.where(forked_from_project_id: project, forked_to_project_id: personal_projects)

    if links.any?
      links.first.forked_to_project
    else
      nil
    end
  end

  def ldap_user?
    extern_uid && provider == 'ldap'
  end

  def accessible_deploy_keys
    DeployKey.in_projects(self.authorized_projects.pluck(:id)).uniq
  end

  def created_by
    User.find_by(id: created_by_id) if created_by_id
  end

  def sanitize_attrs
    %w(name username skype linkedin twitter bio).each do |attr|
      value = self.send(attr)
      self.send("#{attr}=", Sanitize.clean(value)) if value.present?
    end
  end

  def requires_ldap_check?
    if ldap_user?
      !last_credential_check_at || (last_credential_check_at + 1.hour) < Time.now
    else
      false
    end
  end

  def solo_owned_groups
    @solo_owned_groups ||= owned_groups.select do |group|
      group.owners == [self]
    end
  end

  def with_defaults
    User.defaults.each do |k, v|
      self.send("#{k}=", v)
    end

    self
  end

  def can_leave_project?(project)
    project.namespace != namespace &&
      project.project_member(self)
  end

  # Reset project events cache related to this user
  #
  # Since we do cache @event we need to reset cache in special cases:
  # * when the user changes their avatar
  # Events cache stored like  events/23-20130109142513.
  # The cache key includes updated_at timestamp.
  # Thus it will automatically generate a new fragment
  # when the event is updated because the key changes.
  def reset_events_cache
    Event.where(user_id: self.id).
      order('id DESC').limit(1000).
      update_all(updated_at: Time.now)
  end

  def full_website_url
    return "http://#{website_url}" if website_url !~ /^https?:\/\//

    website_url
  end

  def short_website_url
    website_url.gsub(/https?:\/\//, '')
  end

  def all_ssh_keys
    keys.map(&:key)
  end

  def temp_oauth_email?
    email =~ /\Atemp-email-for-oauth/
  end

  def generate_tmp_oauth_email
    self.email = "temp-email-for-oauth-#{username}@gitlab.localhost"
  end
end
