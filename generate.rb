require 'net/http'
require 'json'
require 'date'

def fetch_repos(username, page)
  url = "https://api.github.com/users/#{username}/repos?page=#{page}&per_page=100"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

def get_top_repos(username, count)
  page = 1
  all_repos = []

  loop do
    repos = fetch_repos(username, page)
    break if repos.empty?
    all_repos.concat(repos)
    page += 1
  end

  sorted_repos = all_repos.sort_by { |repo| -repo['stargazers_count'] }
  top_repos = sorted_repos.take(count)

  top_repos.map { |repo| [repo['name'], repo['stargazers_count']] }
end

def generate_markdown_table(data)
  table = "| Repository | Stars |\n| --- | --- |\n"

  data.each do |repo|
    table << "| [#{repo[0]}](https://github.com/tnantoka/#{repo[0]}) | :star: #{repo[1]} |\n"
  end

  table
end

username = 'tnantoka'
top_count = 10

top_repos = get_top_repos(username, top_count)

markdown_table = generate_markdown_table(top_repos)

template = File.read('README.md.template')
template += "Last Updated: #{Date.today}\n\n"
template += markdown_table

puts template
File.write('README.md', template)

