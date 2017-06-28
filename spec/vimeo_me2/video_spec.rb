require "spec_helper"

module VimeoMe2

  describe Video do


    before(:example) do
      VCR.use_cassette("vimeo-video") do
        @own_video = Video.new('2081091e83977725227e878c4127ba39','219689930')
        @delete_video = Video.new('2081091e83977725227e878c4127ba39','219661734')
        @other_user_video = Video.new('2081091e83977725227e878c4127ba39', '222928033')
      end
    end

    context "#initialize" do

      it "initializes with a valid token" do
        expect(@own_video.client.last_request.code).to eq(200)
      end

      it "initializes with a valid token & user" do
        expect(@other_user_video.client.last_request.code).to eq(200)
      end

      it "gives an error when token is wrong" do
        VCR.use_cassette("vimeo-video-error") do
          expect{@user = Video.new('error-vimeo-token','1234')}.to raise_error(VimeoMe2::RequestFailed)
        end
      end
    end

    context "methods" do

      it "returns the correct name" do
        expect(@own_video.name).to eq("test2.mp4")
      end

      it "is able to set a new name" do
        @own_video.name = "new name"
        expect(@own_video.name).to eq("new name")
      end

      it "is possible to save a new name" do
        @own_video.name = "new name"
        VCR.use_cassette("vimeo-video-update") do
          @own_video.update
        end
        expect(@own_video.name).to eq("new name")
      end

      it "is posisble to delete an existing video" do
        VCR.use_cassette("vimeo-video-delete") do
          @delete_video.destroy
        end
        expect(@delete_video.video).to eq(nil)
      end
    end

    context "comments" do

      it "gets all comments" do
        VCR.use_cassette("vimeo-video-comments") do
          @comments = @own_video.comments
        end
        expect(@comments['total']).to eq(2)
        expect(@comments['data'][0]['text']).to eq('comment 2')
      end

      it "can add a comment" do
        VCR.use_cassette("vimeo-video-comments-add") do
          @comments = @own_video.add_comment "tester"
        end
        expect(@comments['text']).to eq("tester")
      end

      it "can view a comment" do
        VCR.use_cassette("vimeo-video-comments-view") do
          @comment = @own_video.view_comment '15844022'
        end
        expect(@comment['text']).to eq('comment 2')
      end

      it "can edit a comment" do
        VCR.use_cassette("vimeo-video-comments-edit") do
          @comment = @own_video.edit_comment '15844022', 'blabla'
        end
        expect(@comment['text']).to eq('blabla')
      end

      it "can delete a comment" do
        VCR.use_cassette("vimeo-video-comments-delete") do
          @comment = @own_video.delete_comment '15844039'
        end
        expect(@own_video.client.last_request.code).to eq(204)
      end

    end

  end

end
