require 'test_helper'

class Api::V1::VersionsControllerTest < ActionController::TestCase
    def test_current_version
        get :check, {version_uid: 'ios/DEVELOPMENT', format: :json}
        assert_response 202
        assert_equal nil, json['url']
    end

    def test_old_version
        get :check, {version_uid: 'ios/old', format: :json}
        assert_response 202
        assert json['url'].present?
    end

    def test_fails_when_version_is_missing
        get :check
        assert_response 400
        assert @response.body.blank?
    end
end
