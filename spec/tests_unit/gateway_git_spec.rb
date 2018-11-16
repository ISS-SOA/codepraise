# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Unit test of git command gateway' do
  CLONE_COMMAND = 'git clone --progress ssh://__.git ./test 2>&1'
  BLAME_COMMAND = 'git blame --line-porcelain test.rb'

  it 'should make the right clone command' do
    command = CodePraise::Git::Command.new
      .clone('ssh://__.git', './test')
      .with_std_error
      .with_progress
      .full_command

    _(command).must_equal CLONE_COMMAND
  end

  it 'should make the right blame command' do
    command = CodePraise::Git::Command.new
      .blame('test.rb', porcelain: true)
      .full_command

    _(command).must_equal BLAME_COMMAND
  end
end
