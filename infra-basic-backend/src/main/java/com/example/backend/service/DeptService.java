package com.example.backend.service;

import com.example.backend.entity.Dept;
import com.example.backend.repository.DeptRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true) // 성능 최적화를 위해 읽기 전용 설정
public class DeptService {

    private final DeptRepository deptRepository;

    public List<Dept> findAll() {
        return deptRepository.findAll();
    }
}