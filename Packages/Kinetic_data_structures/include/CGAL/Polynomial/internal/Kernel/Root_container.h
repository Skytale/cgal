// Copyright (c) 2005  Stanford University (USA).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org); you may redistribute it under
// the terms of the Q Public License version 1.0.
// See the file LICENSE.QPL distributed with CGAL.
//
// Licensees holding a valid commercial license may use this file in
// accordance with the commercial license agreement provided with the software.
//
// This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
// WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// $Source$
// $Revision$ $Date$
// $Name$
//
// Author(s)     : Daniel Russel <drussel@alumni.princeton.edu>

#ifndef CGAL_POLYNOMIAL_INTERNAL_ROOT_CONTAINER_H
#define CGAL_POLYNOMIAL_INTERNAL_ROOT_CONTAINER_H

#include <CGAL/Polynomial/basic.h>
#include <iterator>

CGAL_POLYNOMIAL_BEGIN_INTERNAL_NAMESPACE

template <class K>
class Root_container
{
private:
  typedef Root_container<K> This;
  typedef typename K::Root_stack RE;

public:

  class iterator
  {
  public:
    iterator(){}
    iterator(const RE &re): renum_(re){}

    typedef Root value_type;
    typedef const iterator& reference;
    typedef const value_type * pointer;
    typedef std::size_t difference_type;
    typedef std::forward_iterator_tag iterator_category;

    const value_type &operator*() const
    {
      return renum_.top();
    }
    pointer operator->() const
    {
      return &renum_.top();
    }
    reference operator++() {
      renum_.pop();
      return *this;
    }
    iterator operator++(int) {
      iterator it= *this;
      renum_.pop();
      return it;
    }
    const iterator& operator+(unsigned int i) {
      for (unsigned int j=0; j< i; ++j) {
	operator++();
      }
      return *this;
    }
    bool operator==(const iterator &o) const
    {
      CGAL_Polynomial_precondition(renum_.empty()
				   || o.renum_.empty());
      return renum_.empty() && o.renum_.empty();
    }
    bool operator!=(const iterator &o) const
    {
      CGAL_Polynomial_precondition(renum_.empty()
				   || o.renum_.empty());
      if ( renum_.empty() && o.renum_.empty() ) { return false; }
      return !renum_.empty() || !o.renum_.empty();
    }
  protected:
    RE renum_;
  };

  typedef typename K::Root   Root;
  Root_container(const typename K::Function &fn,
		 const Root &lb,
		 const Root &ub,
		 const K &k)
    : begin_(RE(fn, lb,ub, k.root_stack_traits_object())){}

  const iterator& begin() const
  {
    return begin_;
  }

  iterator end() const
  {
    return iterator();
  }

protected:
  iterator begin_;
};

CGAL_POLYNOMIAL_END_INTERNAL_NAMESPACE
#endif
