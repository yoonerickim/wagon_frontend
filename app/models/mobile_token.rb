class MobileToken < ActiveRecord::Base
  belongs_to :user

  validates :device_uid, presence: true
  validate :check_version

  before_create :create_token

  EXPIRATION = 7.days

  # Public: Refresh the current token if token matches and
  # not past expiration time.
  #
  def refresh
    if current?
      self.expires_at = Time.now + EXPIRATION
    else
      errors.add(:base, "Expired")
    end
    save
  end

  # Public: Test if a token is not past it's expiration.
  #
  def current?
    Time.now < self.expires_at
  end

  private

  # Internal: Check version
  # 
  def check_version
    logger.debug "TODO: Confirm mobile version is sufficient!!!"

    ApiVersion.check(errors, version_uid)
  end

  # Internal: Set token and expire time.
  #
  def create_token
    set_token(:token)
    self.expires_at = Time.now + 30.minutes
  end
  
  # Generate a random, unique token and set the designated 
  # column to that value.
  #
  def set_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64(64) 
    end while self.class.exists?(column => self[column])
  end

end
