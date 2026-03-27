package com.example.backend.controller;

import com.example.backend.entity.Dept;
import com.example.backend.service.DeptService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/depts")
@RequiredArgsConstructor
public class DeptController {

    private final DeptService deptService;

    @GetMapping
    public List<Dept> getAll() {
        return deptService.findAll();
    }
}