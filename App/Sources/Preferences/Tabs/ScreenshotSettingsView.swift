// App/Sources/Preferences/Tabs/ScreenshotSettingsView.swift
import SwiftUI
import SharedKit

struct ScreenshotSettingsView: View {
    @Bindable var viewModel: PreferencesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingGroup(title: "After Capture") {
                SettingCard {
                    SettingRow(label: "Show Preview", sublabel: "Display thumbnail with quick actions") {
                        Toggle("", isOn: $viewModel.screenshotShowPreview)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    SettingRow(label: "Copy to Clipboard", sublabel: "Copy screenshot immediately", showDivider: true) {
                        Toggle("", isOn: $viewModel.screenshotAutoCopy)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    SettingRow(
                        label: "Clipboard Content",
                        sublabel: clipboardContentDescription,
                        showDivider: true
                    ) {
                        Picker("", selection: $viewModel.screenshotClipboardContent) {
                            Text("Image").tag(ScreenshotClipboardContent.image)
                            Text("File Path").tag(ScreenshotClipboardContent.filePath)
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                    if viewModel.screenshotClipboardContent == .image {
                        SettingRow(
                            label: "Clipboard Format",
                            sublabel: "Used whenever a screenshot is copied",
                            showDivider: true
                        ) {
                            Picker("", selection: $viewModel.screenshotClipboardFormat) {
                                Text("PNG").tag(ScreenshotClipboardFormat.png)
                                Text("JPEG").tag(ScreenshotClipboardFormat.jpeg)
                                Text("TIFF").tag(ScreenshotClipboardFormat.tiff)
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    SettingRow(label: "Auto Save", sublabel: "Save to file automatically", showDivider: true) {
                        Toggle("", isOn: $viewModel.screenshotAutoSave)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                }
            }

            SettingGroup(title: "Capture") {
                SettingCard {
                    SettingRow(label: "Show Cursor", sublabel: "Include the mouse pointer in screenshots") {
                        Toggle("", isOn: $viewModel.screenshotShowsCursor)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    SettingRow(label: "Capture Window Shadow", sublabel: "Include shadow in window captures", showDivider: true) {
                        Toggle("", isOn: $viewModel.captureWindowShadow)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    // TODO: Re-enable the rows below once underlying
                    // behaviors are implemented (showMagnifier,
                    // rememberLastCaptureArea).
                }
            }

            SettingGroup(title: "Timestamp") {
                SettingCard {
                    SettingRow(label: "Add Timestamp", sublabel: "Draw the capture time onto screenshots") {
                        Toggle("", isOn: $viewModel.screenshotTimestampEnabled)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }

                    if viewModel.screenshotTimestampEnabled {
                        SettingRow(label: "Position", showDivider: true) {
                            Picker("", selection: $viewModel.screenshotTimestampPosition) {
                                ForEach(ScreenshotTimestampPosition.allCases, id: \.self) { position in
                                    Text(position.displayName).tag(position)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 150)
                        }

                        SettingRow(label: "Format", showDivider: true) {
                            Picker("", selection: $viewModel.screenshotTimestampFormat) {
                                ForEach(ScreenshotTimestampFormat.allCases, id: \.self) { format in
                                    Text(format.displayName).tag(format)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 150)
                        }

                        SettingRow(label: "Color", showDivider: true) {
                            TextField("#FFFFFF", text: $viewModel.screenshotTimestampColorHex)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 12, design: .monospaced))
                                .frame(width: 88)
                        }

                        SettingRow(label: "Font Size", showDivider: true) {
                            HStack(spacing: 8) {
                                Text("\(viewModel.screenshotTimestampFontSize) pt")
                                    .font(.system(size: 13, weight: .medium).monospacedDigit())
                                    .frame(minWidth: 42, alignment: .trailing)
                                Stepper(
                                    "",
                                    value: $viewModel.screenshotTimestampFontSize,
                                    in: ScreenshotTimestampOptions.fontSizeRange
                                )
                                .labelsHidden()
                            }
                        }
                    }
                }
            }

            SettingGroup(title: "Beautify") {
                SettingCard {
                    SettingRow(
                        label: "Beautify Every Screenshot",
                        sublabel: "Uses the background, padding, corners and shadow last set in the editor's Beautify panel"
                    ) {
                        Toggle("", isOn: $viewModel.autoBeautifyScreenshots)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                }
            }

            SettingGroup(title: "Self-Timer") {
                SettingCard {
                    SettingRow(
                        label: "Default Duration",
                        sublabel: "Delay before the screenshot fires"
                    ) {
                        HStack(spacing: 8) {
                            Text("\(viewModel.selfTimerDurationSeconds)s")
                                .font(.system(size: 13, weight: .medium).monospacedDigit())
                                .frame(minWidth: 32, alignment: .trailing)
                            Stepper(
                                "",
                                value: $viewModel.selfTimerDurationSeconds,
                                in: AppSettings.selfTimerDurationRange
                            )
                            .labelsHidden()
                        }
                    }
                    SettingRow(
                        label: "Tick Sound",
                        sublabel: "Play a sound on each second of the countdown",
                        showDivider: true
                    ) {
                        Toggle("", isOn: $viewModel.selfTimerPlayTickSound)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                }

                Text("Useful for capturing menus, hover states, and other UI that disappears the moment you move the mouse.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            CapturePresetSettingsSection(viewModel: viewModel)

        }
    }

    private var clipboardContentDescription: LocalizedStringResource {
        switch viewModel.screenshotClipboardContent {
        case .image:
            "Copy image data to the clipboard"
        case .filePath:
            "Copy the saved path, or keep a temporary file for 24 hours"
        }
    }
}
