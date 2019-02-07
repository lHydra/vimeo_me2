$:.unshift(File.dirname(__FILE__))
require "http/http_request"
require "video/comment"

module VimeoMe2
  class Video < VimeoMe2::VimeoObject
    include VimeoMe2::VideoMethods::Comment

    attr_reader :video, :video_id

    def initialize token, video_id
      set_uri video_id
      @video = super(token)
    end

    def load video_id
      @video = initialize(@token, video_id)
    end

    def reload
      raise "No video selected, use load first" if @base_uri.nil?
      @video = initialize(@token, @video_id)
    end

    def name= name
      @video['name'] = name
    end

    def name
      @video['name']
    end

    def privacy
      @video['privacy'] ||= {}
    end

    def password= password
      @video['password'] = password
    end

    def duration
      @video['duration']
    end

    # STATUSES

    def status
      @video['status']
    end

    def upload_status
      @video.dig('upload', 'status')
    end

    def transcode_status
      @video.dig('transcode', 'status')
    end

    def privacy= privacy_options
      privacy.merge! privacy_options
    end

    def available?
      status == 'available'
    end

    def transcoding_error?
      status == 'transcoding_error'
    end

    def unavailable?
      status == 'unavailable'
    end

    def uploading_error?
      status == 'uploading_error'
    end

    def update(params = {})
      body = @video.merge(params)
      # temporary fix, because API does not accept privacy in request
      body.delete('privacy')
      patch(nil, body: body, code: [200,204])
    end

    def destroy
      @video = delete(nil, code: 204)
      @base_uri, @video_id = nil
    end

    private

    def set_uri video_id
      @video_id = video_id
      @base_uri = /videos?/.match(video_id.to_s) ? video_id : "/videos/#{video_id.to_s}"
    end
  end
end
