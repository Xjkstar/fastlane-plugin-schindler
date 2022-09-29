describe Fastlane::Actions::SchindlerAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The schindler plugin is working!")

      Fastlane::Actions::SchindlerAction.run(nil)
    end
  end
end
