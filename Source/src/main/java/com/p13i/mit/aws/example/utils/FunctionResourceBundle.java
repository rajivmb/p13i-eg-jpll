package com.p13i.mit.aws.example.utils;

import java.text.MessageFormat;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

//<Ref/> https://murygin.wordpress.com/2010/04/23/parameter-substitution-in-resource-bundles/

public class FunctionResourceBundle {
    // if property file is: package/name/messages.properties then bundle name will be package.name.messages
    private static final String BUNDLE_NAME = "function";
    private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle(BUNDLE_NAME);

    private FunctionResourceBundle() { }

    public static String getString(String key) {
        try {
            return RESOURCE_BUNDLE.getString(key);
        } catch (MissingResourceException e) {
            return '!' + key + '!';
        }
    }
    public static String getString(String key, Object... params  ) {
        try {
            return MessageFormat.format(RESOURCE_BUNDLE.getString(key), params);
        } catch (MissingResourceException e) {
            return '!' + key + '!';
        }
    }
}
