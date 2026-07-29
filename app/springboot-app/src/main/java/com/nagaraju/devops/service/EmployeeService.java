package com.nagaraju.devops.service;

import com.nagaraju.devops.model.Employee;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class EmployeeService {

    private final List<Employee> employees = new ArrayList<>();

    public EmployeeService() {
        employees.add(new Employee(1L, "John Doe", "DevOps", "john@example.com"));
        employees.add(new Employee(2L, "Jane Smith", "Cloud", "jane@example.com"));
    }

    public List<Employee> getAllEmployees() {
        return employees;
    }

    public Employee addEmployee(Employee employee) {
        employees.add(employee);
        return employee;
    }
}