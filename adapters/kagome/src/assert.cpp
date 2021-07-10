#include "assert.hpp"

#include <sstream>

namespace boost {

  void assertion_failed(char const * expr, char const * function, char const * file, long line) {
    std::stringstream ss;
    ss << "Assert inside function '" << function
       << "' in file '" << file
       << "' on line '" << line
       << "' when evaluating '" << expr
       << "'";

    throw std::runtime_error(ss.str());
  }

  void assertion_failed_msg(char const * expr, char const * msg, char const * function, char const * file, long line) {
    std::stringstream ss;
    ss << "Error inside function '" << function
       << "' in file '" << file
       << "' on line '" << line
       << "' when evaluating '" << expr
       << "': " << msg;

    throw std::runtime_error(ss.str());
  }

} // namespace boost
