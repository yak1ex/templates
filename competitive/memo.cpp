#include <iostream>
#include <regex>

void regex()
{
	std::smatch sm;
	std::string target("This is a test sentence");
	if(std::regex_match(target, sm, std::regex(".*"))) {
		for(auto subm : sm) {
			std::cout << std::string(subm.first, subm.second) << std::endl;
		}
	}
	if(std::regex_search(target, sm, std::regex(" ([a-z])"))) {
		for(auto subm : sm) {
			std::cout << (subm.matched ? std::string(subm.first, subm.second) : std::string("NOT MATCHED")) << std::endl;
		}
	}
	auto result = std::regex_replace(target, std::regex(" [a-z]"), "|$&|");
	std::cout << result << std::endl;
	auto result2 = std::regex_replace(target, std::regex(" [a-z]"), "|$&|", std::regex_constants::format_first_only);
	std::cout << result2 << std::endl;
}

int main(void)
{
	return 0;
}
