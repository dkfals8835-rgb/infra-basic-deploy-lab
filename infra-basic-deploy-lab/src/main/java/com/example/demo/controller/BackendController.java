package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class BackendController {

    @GetMapping("/backend")
    public String backend() {
        return "backend";
    }
    
    @GetMapping("/backend2")
    public String backend2() {
        return "backend2";
    }
    
    @GetMapping("/backend3")
    public String backend3() {
        return "backend3";
    }
}
