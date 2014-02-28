# This module handles verifiying that the mobile version is up-to-date
#
# Version_uids look like PLATFORM/vMAJOR.MINOR-revision-hash
# 
module ApiVersion

  # Public: Check if a version_uid is supported.
  #
  # adds an errors to errors if version is not supported
  def self.check(errors, version_uid)
    platform, version = self.classify_version(version_uid)
    errors.add(:base, 'Version too old. Please update.') unless self.version_current?(platform, version)
  end


  # Public: return url for upgrade
  #
  # return a url to show if an upgrade is available, otherwise returns nil
  def self.url(version_uid)
    platform, version = self.classify_version(version_uid)
    platform["url"] unless self.version_current?(platform, version)
  end

  # Private: given a version, and a list of acceptable versions
  # checks if the version is allowed
  #
  # Return true if versions is in versions, or is a minor upgrade to the last
  # entry in versions
  def self.allowed?(version, versions)
     if versions.include? version
       true
     else
        version_code = self.as_version(version)
        latest_version = self.as_version(versions.last)
        version_code[0] == latest_version[0] and version_code[1] >= latest_version[1]
     end
  end

  private

  # returns true if the given version is allowed by the platform
  def self.version_current?(platform, version)
    self.allowed?(version, platform["allowed_versions"])
  end

  # Takes a verson code of the form MAJOR-revision-HASH and returns
  # [MAJOR, revision]
  def self.as_version(version)
    match = /^([^-]+)-(\d+)-/.match(version)
    if match.present?
      [match[1], Integer(match[2])]
    else
      [version, 0]
    end
  end

  # Takes a version uid of the form platform/something
  # and divides it into the two parts
  def self.classify_version(uid)
    platform, version = uid.split("/", 2)
    if version.present?
      [self.platform_config(platform), version]
    else
      [self.platform_config('error'), uid]
    end
  end

  # returns the configuration for a platform
  # or a default that acccepts no versions
  def self.platform_config(platform)
    if MOBILE_CONFIG[platform].present?
      MOBILE_CONFIG[platform]
    else
      {"allowed_versions" => []}
    end
  end
end
