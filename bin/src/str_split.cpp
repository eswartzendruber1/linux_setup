#include <string>
#include <algorithm>
#include <iterator>
#include <iostream>
#include <vector>
 
//template <class Container>
//void split3(const std::string& str, Container& cont,
//              char delim = ' ')
//{
//    std::size_t current, previous = 0;
//    current = str.find(delim);
//    while (current != std::string::npos) {
//        cont.push_back(str.substr(previous, current - previous));
//        previous = current + 1;
//        current = str.find(delim, previous);
//    }
//    cont.push_back(str.substr(previous, current - previous));
//}

void str_split_0()
{
  int i = 0;
  std::vector<std::string> mem_type_vec;
  std::string mem_type = "bm,ocm,ddr";
  
  std::size_t current, previous = 0;
  current = mem_type.find(",");
  while (current != std::string::npos) {
    mem_type_vec.push_back(mem_type.substr(previous, current - previous));
    previous = current + 1;
    current = mem_type.find(",", previous);
  }
  mem_type_vec.push_back(mem_type.substr(previous, current - previous));

  for (i=0; i < mem_type_vec.size(); i++) {
    std::cout << "mem_type_vec[" << i << "] = " << mem_type_vec[i] << "\n";
  }

//  while (!mem_type_vec.empty()) {
//    mem_type_vec.pop_back();
//  //std::cout << mem_type_vec.pop_back() << "\n";
//  }
  
}

//void str_split_1()
//{
//  int i = 0;
//  std::vector<std::string> mem_type_vec;
//  std::string* mem_type_array;
//  char delim = ',';
//  std::string tmp = "";
//  std::string mem_type = "bm,ocm,ddr";
//  int count = std::count(mem_type.begin(), mem_type.end(), delim) + 1;
//  mem_type_array = new std::string[count];
//  
//  std::cout << "mem_type = " << mem_type << "\n";
//  std::cout << "delim = " << delim << "\n";
//  std::cout << "count = " << count << "\n";
//
//  std::size_t current, previous = 0;
//  current = mem_type.find(delim);
//  std::cout << "current = " << current << "\n";
//
//  count = 0;
//  while (current != std::string::npos) {
//    tmp = mem_type.substr(previous, current - previous);
//    previous = current + 1;
//    current = mem_type.find(delim, previous);
//    std::cout << "Adding: mem_type_array[" << count << "] = " << tmp << "\n";
//    mem_type_array[count] = tmp;
//    mem_type_vec.push_back(tmp);
//    count++;
//  }
//  tmp = mem_type.substr(previous, current - previous);
//  std::cout << "Adding: mem_type_array[" << count << "] = " << tmp << "\n";
//  mem_type_array[count] = tmp;
//  mem_type_vec.push_back(tmp);
//  //std::cout << "tmp = " << tmp << "\n";
//  for (i=0; i <= count; i++) {
//    std::cout << "mem_type_array[" << i << "] = " << mem_type_array[i] << "\n";
//    std::cout << "mem_type_vec[" << i << "] = " << mem_type_vec[i] << "\n";
//  }
//  std::cout << "mem_type_vec.size() = " << mem_type_vec.size() << "\n";
//  
//}

int main() {
  str_split_0();
  //str_split_1();
}
