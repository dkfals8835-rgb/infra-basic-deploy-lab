package com.example.backend.repository;

import com.example.backend.entity.Dept;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DeptRepository extends JpaRepository<Dept, Integer> {
    // 기본적인 CRUD 메서드가 자동으로 생성됩니다.
}