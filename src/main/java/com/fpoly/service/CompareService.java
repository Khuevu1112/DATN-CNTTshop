package com.fpoly.service;

import java.util.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fpoly.model.Product;
import com.fpoly.model.ProductSpec;
import com.fpoly.model.dto.CompareRow;
import com.fpoly.repository.ProductRepository;

@Service
public class CompareService {

    @Autowired
    private ProductRepository productRepository;

    private static final int MAX_COMPARE = 4;

    public List<Product> layDanhSachSanPham(List<Integer> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return new ArrayList<>();
        }
        if (productIds.size() > MAX_COMPARE) {
            productIds = productIds.subList(0, MAX_COMPARE);
        }

        List<Product> found = productRepository.findByIdIn(productIds);

        Map<Integer, Product> byId = new HashMap<>();
        for (Product p : found) {
            byId.put(p.getId(), p);
        }

        List<Product> ordered = new ArrayList<>();
        for (Integer id : productIds) {
            if (byId.containsKey(id)) {
                ordered.add(byId.get(id));
            }
        }
        return ordered;
    }

    public List<CompareRow> xayDungBangSoSanh(List<Product> products) {
        if (products.isEmpty()) {
            return new ArrayList<>();
        }

        LinkedHashSet<String> allKeys = new LinkedHashSet<>();
        Map<String, Map<Integer, String>> valueByKeyAndProduct = new HashMap<>();

        for (Product p : products) {
            List<ProductSpec> specs = p.getSpecs();
            if (specs == null) continue;

            specs.sort(Comparator.comparing(
                    s -> s.getSortOrder() != null ? s.getSortOrder() : 0
            ));

            for (ProductSpec spec : specs) {
                String key = spec.getSpecKey();
                allKeys.add(key);
                valueByKeyAndProduct
                        .computeIfAbsent(key, k -> new HashMap<>())
                        .put(p.getId(), spec.getSpecValue());
            }
        }

        List<CompareRow> rows = new ArrayList<>();
        for (String key : allKeys) {
            String[] values = new String[products.size()];
            for (int i = 0; i < products.size(); i++) {
                Integer pid = products.get(i).getId();
                values[i] = valueByKeyAndProduct
                        .getOrDefault(key, Collections.emptyMap())
                        .getOrDefault(pid, "—");
            }
            rows.add(new CompareRow(key, values));
        }

        return rows;
    }

    public int getMaxCompare() {
        return MAX_COMPARE;
    }
}