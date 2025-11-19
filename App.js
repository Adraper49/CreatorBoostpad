import React from "react";
import { View, Text, TouchableOpacity, StyleSheet, Image, ScrollView, Alert } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons, MaterialIcons } from "@expo/vector-icons";

const PRIVACY_URL = "https://docs.google.com/document/d/1gLjnSGn10qZZgDIBuRVKnW7nOtw34YwJZwuMuam_L2k/edit?usp=sharing";
const TERMS_URL   = "https://docs.google.com/document/d/1SjoQjDq_LhEVmDlG_xvghwhITyFDofZwKHuxd6WO7ug/edit?usp=sharing";

export default function App() {
  return (
    <LinearGradient colors={["#0F172A", "#0B1226"]} style={{ flex: 1 }}>
      <SafeAreaView style={styles.safe}>
        <ScrollView contentContainerStyle={{ padding: 20 }}>
          {/* Header / Hero */}
          <View style={styles.hero}>
            <Image
              source={require("./assets/boostpad_store_icon_512.png")}
              style={styles.heroIcon}
              resizeMode="contain"
            />
            <View style={{ flex: 1 }}>
              <Text style={styles.title}>Creator BoostPad</Text>
              <Text style={styles.subtitle}>Create. Boost. Publish.</Text>
            </View>
          </View>

          {/* Primary CTAs */}
          <View style={styles.rowWrap}>
            <PrimaryButton
              icon={<MaterialIcons name="rocket-launch" size={22} color="#fff" />}
              label="Generate Media Kit"
              onPress={() => Alert.alert("Media Kit", "Media Kit Generator coming soon")}
            />
            <PrimaryButton
              icon={<Ionicons name="calendar-outline" size={22} color="#fff" />}
              label="Open Scheduler"
              onPress={() => Alert.alert("Scheduler", "Smart Scheduler coming soon")}
            />
          </View>

          {/* Secondary feature cards */}
          <Text style={styles.sectionTitle}>Boost your content</Text>
          <View style={styles.rowWrap}>
            <FeatureCard
              icon={<Ionicons name="cut-outline" size={22} color="#60A5FA" />}
              title="Auto Clips"
              caption="Detect highlights & trim in seconds."
            />
            <FeatureCard
              icon={<Ionicons name="text-outline" size={22} color="#60A5FA" />}
              title="Smart Captions"
              caption="Readable, on-brand subtitles."
            />
            <FeatureCard
              icon={<Ionicons name="flash-outline" size={22} color="#60A5FA" />}
              title="Trendy Hooks"
              caption="Proven openers that convert."
            />
          </View>

          {/* Footer links */}
          <View style={styles.footerLinks}>
            <Text style={styles.link} onPress={() => open(PRIVACY_URL)}>Privacy</Text>
            <Text style={styles.dot}>•</Text>
            <Text style={styles.link} onPress={() => open(TERMS_URL)}>Terms</Text>
          </View>

          <Text style={styles.foot}>Build path: C:\\KB\\Apps\\CreatorBoostpad</Text>
        </ScrollView>
      </SafeAreaView>
    </LinearGradient>
  );
}

function open(url) {
  // Lazy import to avoid requiring Linking in web bundle warnings
  import("react-native").then(({ Linking }) => Linking.openURL(url));
}

function PrimaryButton({ icon, label, onPress }) {
  return (
    <TouchableOpacity style={styles.primaryBtn} onPress={onPress}>
      <View style={{ marginRight: 8 }}>{icon}</View>
      <Text style={styles.primaryText}>{label}</Text>
    </TouchableOpacity>
  );
}

function FeatureCard({ icon, title, caption }) {
  return (
    <View style={styles.card}>
      <View style={styles.cardIcon}>{icon}</View>
      <Text style={styles.cardTitle}>{title}</Text>
      <Text style={styles.cardCaption}>{caption}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  hero: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 18
  },
  heroIcon: { width: 64, height: 64, marginRight: 14 },
  title: { color: "white", fontSize: 28, fontWeight: "800" },
  subtitle: { color: "#C7D2FE", marginTop: 4, fontSize: 14 },
  rowWrap: { flexDirection: "row", flexWrap: "wrap", gap: 12 },

  primaryBtn: {
    backgroundColor: "#2563EB",
    borderRadius: 14,
    paddingVertical: 14,
    paddingHorizontal: 16,
    flexDirection: "row",
    alignItems: "center",
    minWidth: 260,
    flexGrow: 1
  },
  primaryText: { color: "white", fontWeight: "700", fontSize: 15, flexShrink: 1 },

  sectionTitle: { color: "white", fontSize: 16, fontWeight: "800", marginTop: 20, marginBottom: 8 },

  card: {
    backgroundColor: "#0b1226",
    borderColor: "#334155",
    borderWidth: 1,
    borderRadius: 14,
    padding: 14,
    width: "31%",
    minWidth: 220,
    flexGrow: 1
  },
  cardIcon: {
    width: 36, height: 36, borderRadius: 8,
    backgroundColor: "rgba(96,165,250,0.15)", alignItems: "center", justifyContent: "center", marginBottom: 10
  },
  cardTitle: { color: "white", fontWeight: "800", marginBottom: 4 },
  cardCaption: { color: "#A7B0C4" },

  footerLinks: { flexDirection: "row", alignItems: "center", justifyContent: "center", marginTop: 24 },
  link: { color: "#93C5FD", fontWeight: "700" },
  dot: { color: "#475569", marginHorizontal: 8 },
  foot: { color: "#94A3B8", fontSize: 12, marginTop: 10, textAlign: "center" }
});
