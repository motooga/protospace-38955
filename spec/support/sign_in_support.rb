module SignInSupport
  def sign_in(user)
    # ログイン画面に遷移する
    visit root_path
    click_on('ログイン')
    # 必要な情報を埋めるとログインが成功してトップページに遷移する
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    find('input[name="commit"]').click
    sleep 1

    expect(current_path).to eq(root_path)
  end
end