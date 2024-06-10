# frozen_string_literal: true

require 'spec_helper'

describe Sinatra::Application do
  describe 'GET to /' do
    subject(:response) { get '/' }

    it { expect(response.status).to eq 200 }

    context 'when tags are found' do
      subject(:body) { response.body }

      it { expect(body).to have_tag(:title, value: match(/Video Downloader UI/)) }

      it { expect(body).to have_tag(:form, method: 'post', action: '/downloads') }
      it { expect(body).to have_tag(:input, type: 'text', name: 'code') }
      it { expect(body).to have_tag(:button, type: 'submit', name: 'Download') }
    end
  end
end
