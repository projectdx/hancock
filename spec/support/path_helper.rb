module PathHelper
  def fixture_directory_path
    Pathname.new(File.dirname(__FILE__)).join('..', '..', 'spec', 'fixtures').expand_path
  end

  def fixture_path(path)
    fixture_directory_path.join(path)
  end

  def request_body(name)
    body = File.read(fixture_directory_path.join('request_bodies', "#{name}.txt"))
    "\r\n#{body.gsub(/\n/, "\r\n").strip}\r\n"
  end

  def response_body(name)
    File.read(fixture_directory_path.join('response_bodies', "#{name}.json"))
  end
end
