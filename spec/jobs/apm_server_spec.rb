require 'rspec'
require 'yaml'
require 'bosh/template/test'

describe 'apm-server job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('apm-server') }
  let(:elasticsearch_link) {
    Bosh::Template::Test::Link.new(
      name: 'elasticsearch',
      instances: [
        Bosh::Template::Test::LinkInstance.new(address: '10.0.0.1'),
        Bosh::Template::Test::LinkInstance.new(address: '10.0.0.2'),
        Bosh::Template::Test::LinkInstance.new(address: '10.0.0.3')
      ],
      properties: {
        'elasticsearch'=> {
            'cluster_name' => 'test'
        }
      }
    )
  }

  describe 'apm-server.yml' do
    let(:template) { job.template('config/apm-server.yml') }

    it 'configure its own host and port right' do
      config = YAML.load(template.render(
        {
          'apm-server' => {
            'host' => 'localhost',
            'port' => 8200 
          } 
        },
        consumes: []
      )
    )
    expect(config['apm-server']['host']).to eq('localhost:8200')
    end

    it 'configures elastic search hosts from properties succesfully' do
      config = YAML.load(template.render(
          {
            'apm-server' => {
              'elasticsearch' => {
                'prefer_bosh_link' => false,
                'protocol' => 'https',
                'port' => 9201,
                'hosts' => ['127.0.0.1','127.0.0.2']
              }
            } 
          },
          consumes: []
        )
      )
      expect(config['output.elasticsearch']['hosts']).to eq([
          'https://127.0.0.1:9201',
          'https://127.0.0.2:9201'
        ]
      )
    end

    it 'configures elastic search hosts from link succesfully' do
        config = YAML.load(template.render({
            'apm-server' => {
              'elasticsearch' => {
                'prefer_bosh_link' => true,
                'protocol' => 'https',
                'port' => 9201,
                'hosts' => ['127.0.0.1','127.0.0.2']
              }
            }
          },
          consumes: [elasticsearch_link]
          )
        )
        expect(config['output.elasticsearch']['hosts']).to eq(
            [
                'https://10.0.0.1:9201',
                'https://10.0.0.2:9201',
                'https://10.0.0.3:9201'
            ]
        )
      end
  end
end