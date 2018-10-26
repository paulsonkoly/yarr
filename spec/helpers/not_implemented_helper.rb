def does_not_implement(name)
  describe "##{name}" do
    it 'raises NotImplementedError' do
      expect { subject.send name }.to raise_error NotImplementedError
    end
  end
end
