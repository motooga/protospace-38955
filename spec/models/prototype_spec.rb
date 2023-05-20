require 'rails_helper'

RSpec.describe Prototype, type: :model do
  before do
    @prototype = FactoryBot.build(:prototype)
  end
  describe 'プロトタイプの投稿' do
    context '新規投稿ができる' do
      it "title,catch_copy,conceptの値と画像があれば保存ができる" do
        expect(@prototype).to be_valid
      end
    end

    context '新規投稿ができない場合' do
      it 'titleが空では登録できない' do
        @prototype.title = ''
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include("Title can't be blank")
      end

      it 'catch_copyが空では登録できない' do
        @prototype.catch_copy = ''
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include("Catch copy can't be blank")
      end

      it 'conceptが空では登録できない' do
        @prototype.concept = ''
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include("Concept can't be blank")
      end

      it '画像が空では登録できない' do
        @prototype.image = nil
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include("Image can't be blank")
      end

      it 'userが紐づいていないと登録できない' do
        @prototype.user = nil
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include('User must exist')
      end
    end
  end
    

end
