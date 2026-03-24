package com.example.demo.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "items")
public class Item {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    protected Item() {}

    public Item(String name) {
        this.name = name;
    }

    public Long getId() { return id; }
    public String getName() { return name; }
}