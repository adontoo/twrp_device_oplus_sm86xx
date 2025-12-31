/*
 * Copyright (C) 2022-2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android-base/parseint.h>
#include <android-base/properties.h>
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include <fs_mgr.h>
#include <unordered_map>

using android::base::GetProperty;
using android::fs_mgr::GetKernelCmdline;

const std::unordered_map<int, std::string> kRegionSuffixMap = {
    {27,    "IN"},
    {55,    "RU"},
    {68,    "EEA"},
    {151,   ""},    // CN
    {161,   "NA"},
    {167,   ""},    // GLO
    {0,     ""},    // Default
};

struct ModelInfo {
    const char* brand;              // ro.product.brand
    const char* device;             // ro.product.device
    const char* manufacturer;       // ro.product.manufacturer
    const char* model;              // ro.product.model
    const char* base_name;          // ro.product.name  w/o region suffix
    const char* twversion;          // ro.twrp.device_version
    const char* supportSpr;         // vendor.display.enable_spr
};

const std::unordered_map<int, ModelInfo> kModelInfoMap = {
    {23851, {"OnePlus", "OP5D2BL1", "OnePlus", "PKG110",    "PKG110",  "OnePlus-ACE-5",         "0"}},    
    {23867, {"OnePlus", "OP5D3BL1", "OnePlus", "CPH2691",   "CPH2691", "OnePlus-13-R",          "0"}},
    {23868, {"OnePlus", "OP5D3BL1", "OnePlus", "CPH2645",   "CPH2645", "OnePlus-13-R",          "0"}},
    {23869, {"OnePlus", "OP5D3BL1", "OnePlus", "CPH2647",   "CPH2647", "OnePlus-13-R",          "0"}},
    {23803, {"OnePlus", "OP5CFBL1", "OnePlus", "PJF110",    "PJF110",  "OnePlus-ACE-3-V",       "0"}},
    {24211, {"OnePlus", "OP5E93L1", "OnePlus", "CPH2661",   "CPH2661", "OnePlus-NORD-4",        "0"}},
    {23814, {"OnePlus", "OP5D06L1", "OnePlus", "PJX110",    "PJX110",  "OnePlus-ACE-3-Pro",     "0"}},
    {23631, {"Realme",  "RE5C4FL1", "Realme",  "RMX3800",   "RMX3800", "Realme-GT-6",           "0"}},
    {22825, {"OnePlus", "OP5929L1", "OnePlus", "PJD110",    "PJD110",  "Oneplus-12",            "0"}},
    {22861, {"OnePlus", "OP595DL1", "OnePlus", "CPH2573",   "CPH2573", "Oneplus-12",            "0"}},
    {22111, {"OPPO",    "OP565FL1", "OPPO",    "PHY110",    "PHY110",  "OPPO-Find-X7-Ultra",    "0"}},
    {22112, {"OPPO",    "OP5660L1", "OPPO",    "PHY120",    "PHY120",  "OPPO-Find-X7-Ultra-SL", "0"}},
    {0,     {"OPLUS",   "SM86XX",   "OPLUS",   "SM86XX",    "SM86XX",  "OPLUS",                 "0"}}, // Default
};

/*
 * SetProperty does not allow updating read only properties and as a result
 * does not work for our use case. Write "OverrideProperty" to do practically
 * the same thing as "SetProperty" without this restriction.
 */
void OverrideProperty(const char* name, const char* value) {
    size_t valuelen = strlen(value);

    prop_info* pi = (prop_info*)__system_property_find(name);
    if (pi != nullptr) {
        __system_property_update(pi, value, valuelen);
    } else {
        __system_property_add(name, strlen(name), value, valuelen);
    }
}

void SetupModelProperties(const ModelInfo& info, const std::string& region) {
    std::string name = info.base_name + region;
    struct PropPair {
        const char* key;
        const char* value;
    } props[] = {
        {"ro.product.brand",                info.brand},
        {"ro.product.device",               info.device},
        {"ro.product.manufacturer",         info.manufacturer},
        {"ro.product.model",                info.model},
        {"ro.product.name",                 name.c_str()},
        {"vendor.display.enable_spr",       info.supportSpr},
        {"ro.product.system.device",        info.model},
        {"ro.product.product.model",        info.model},
        {"ro.product.system.model",         info.model},
        {"ro.product.system_ext.model",     info.model},
        {"ro.product.vendor.model",         info.model},
        {"ro.product.odm.model",            info.model},
        {"ro.product.odm.model",            info.model},
        {"ro.product.vendor.device",        info.device},
        {"ro.product.odm.device",           info.device},
        {"ro.product.product.device",       info.device},
        {"ro.product.system_ext.device",    info.device},
        {"ro.twrp.device_version",          info.twversion},
        {"ro.build.date.utc",               "0"},
    };
    for (const auto& p : props) {
        OverrideProperty(p.key, p.value);
    }
}

void vendor_load_properties() {
    std::string buf = "0";
    GetKernelCmdline("oplus_region", &buf);

    auto region = std::stoi(buf);
    auto region_suffix_iter = kRegionSuffixMap.find(region);

    // Handle unknown regions gracefully
    if (region_suffix_iter == kRegionSuffixMap.end()) {
        LOG(WARNING) << "Unknown oplus_region: " << region << ", using default";
        region_suffix_iter = kRegionSuffixMap.find(0);
    }

    auto prjname = std::stoi(GetProperty("ro.boot.prjname", "0"));
    auto model_info = kModelInfoMap.find(prjname);

    // Handle unknown device models
    if (model_info == kModelInfoMap.end()) {
        LOG(ERROR) << "Unknown prjname: " << prjname << ", using default";
        model_info = kModelInfoMap.find(0);
    }

    SetupModelProperties(model_info->second, region_suffix_iter->second);
}
